mod args;
use args::Args;
mod lut;
use lut::{ArgRestrict, Lut};
mod parse;
use parse::{Rule, VsisaParser};
mod util;
use util::StringUtil;

use clap::Parser as ClapParser;
use pest::{Parser as PestParser, iterators::Pair};
use std::collections::{HashMap, HashSet};

const LABEL_NOEXIST: i16 = -1; // placeholder value for labels that have not been found yet
const NOP_PAD: &str = "NOP_PAD!!!!";

#[derive(Debug)]
enum ParseError {
    InvalidLabel,
    BadArg,
    BadOp,
    Hazard,
}

/// Fill to EOW for N length
fn fill_to_eow(icnt: &mut usize, n: u8, lstring: &mut String, pc: &u8) {
    println!("Filling pc {pc}");
    while *icnt < n.into() {
        lstring.push_str(NOP_PAD);
        *icnt += 1;
    }
}

fn parse_line_helper(
    line: &Pair<Rule>,
    pc: &mut u8,
    labels: &mut HashMap<String, i16>,
    r_hazards: &mut HashSet<String>,
    w_hazards: &mut HashSet<String>,
    icnt: &mut usize,
    lstring: &mut String,
    n: u8,
    out: &mut String,
) {
    match parse_line(line, pc, labels, r_hazards, w_hazards) {
        // no errors
        Ok((instr, was_instruction, was_branch)) => {
            if was_instruction {
                *out += instr.as_str();
                *icnt += 1;
                if was_branch {
                    fill_to_eow(icnt, n, lstring, &pc);
                }
            }
        }
        Err(e) => match e {
            // hazard encountered, fill to EOL and retry
            ParseError::Hazard => {
                fill_to_eow(icnt, n, lstring, &pc);

                // clear
                *icnt = 0;
                lstring.push('\n');
                out.push_str(lstring.as_str());
                *lstring = "".to_string();
                *w_hazards = HashSet::new();
                *r_hazards = HashSet::new();
                *pc += 1;

                // retry
                parse_line_helper(
                    line, pc, labels, r_hazards, w_hazards, icnt, lstring, n, out,
                );
            }
            // user fucked up
            _ => {
                panic!("{:?}", e);
            }
        },
    }
}

/// parse an entire asm file, loaded from user arguments
fn main() -> Result<(), ParseError> {
    // setup
    let args = Args::parse();
    let s = args.read();

    let file = VsisaParser::parse(Rule::file, &s)
        .expect("unsuccessful parse")
        .next()
        .unwrap();
    let mut out = String::with_capacity(256);

    // assemble
    let mut pc: u8 = 0; // program counter
    let mut labels: HashMap<String, i16> = HashMap::new(); // store program counter of label
    let mut lstring: String = "".to_string(); // line string
    let mut icnt = 0; // instruction count for line
    let mut r_hazards: HashSet<String> = HashSet::new();
    let mut w_hazards: HashSet<String> = HashSet::new();

    for line in file.into_inner() {
        match line.as_rule() {
            Rule::line => {
                parse_line_helper(
                    &line,
                    &mut pc,
                    &mut labels,
                    &mut r_hazards,
                    &mut w_hazards,
                    &mut icnt,
                    &mut lstring,
                    args.wordlength,
                    &mut out,
                );
            }
            Rule::EOI => {
                // fill to EOL
                if icnt > 0 {
                    fill_to_eow(&mut icnt, args.wordlength, &mut lstring, &pc);
                }
            }
            _ => unreachable!("{line}"),
        }
        // carriage return on saturated instruction word
        if icnt >= args.wordlength.into() {
            icnt = 0;
            lstring.push('\n');
            out.push_str(lstring.as_str());
            lstring = "".to_string();
            w_hazards = HashSet::new();
            r_hazards = HashSet::new();
            pc += 1;
        }
    }

    // fill
    out = out.replace(NOP_PAD, format!("{:0<32b}", 0).as_str());

    // substitute labels
    for (k, v) in labels.iter() {
        if *v == LABEL_NOEXIST {
            println!("invalid label '{k}'.");
            return Err(ParseError::InvalidLabel);
        }
        out = out.replace(&format!("{{{k}}}"), format!("{:0<8b}", v).as_str());
    }

    // write
    args.write(out);
    return Ok(());
}

/// Parse a single line and update global state
/// Returns (line, was_instruction, was_branch)
fn parse_line(
    line: &Pair<Rule>,
    pc: &u8,
    labels: &mut HashMap<String, i16>,
    r_hazards: &mut HashSet<String>,
    w_hazards: &mut HashSet<String>,
) -> Result<(String, bool, bool), ParseError> {
    let mut out: String = String::new();
    let lstr = line.as_str().to_string();
    let mut inr = line.clone().into_inner();
    let len = inr.len();

    let mut pending_w_haz: Vec<String> = Vec::new();
    let mut pending_r_haz: Vec<String> = Vec::new();

    if len == 0 {
        // comment or blank
        return Ok((out, false, false));
    }

    let first = inr.nth(0).unwrap();
    if len == 1 {
        // must be label
        assert!(first.as_rule() == Rule::label, "error in {lstr}");
        println!("Label '{}' found at pc {pc}", first.as_str());
        labels.insert(first.as_str().to_string(), *pc as i16);
        return Ok((out, false, false));
    }
    // otherwise must be instruction
    assert!(first.as_rule() == Rule::instr);
    let mut was_branch = false;
    if let Some(s) = Lut::instr(first.as_str())
        && let Some(restrict) = Lut::instr_restrict(first.as_str())
    {
        out.push_str(*s);

        was_branch = Lut::is_branch_op(first.as_str());

        // add arguments
        let mut i: usize = 0;
        for field in inr {
            // assert field restrictions of instruction type
            let this_arg_type = match field.as_rule() {
                Rule::reg => ArgRestrict::Reg,
                Rule::literal | Rule::label => ArgRestrict::Lit,
                _ => unreachable!(),
            };
            if restrict[i] != this_arg_type {
                println!(
                    "invalid argument type of '{}' to '{}' in '{lstr}'.",
                    field.as_str(),
                    first.as_str()
                );
                return Err(ParseError::BadArg);
            }

            // resolve argument
            match field.as_rule() {
                // register
                Rule::reg => {
                    if let Some(r) = Lut::reg(field.as_str()) {
                        out.push_str(*r);
                        // check hazards
                        // target (write)
                        if i == 0 {
                            if w_hazards.contains(*r) || r_hazards.contains(*r) {
                                return Err(ParseError::Hazard);
                            }
                            pending_w_haz.push(r.to_string());
                        }
                        // operand (read)
                        else {
                            if w_hazards.contains(*r) {
                                return Err(ParseError::Hazard);
                            }
                            pending_r_haz.push(r.to_string());
                        }
                    } else {
                        println!("invalid register '{}' in '{lstr}'.", field.as_str(),);
                        return Err(ParseError::BadArg);
                    }
                }
                // literal
                Rule::literal => {
                    let dec = match &field.as_str()[..2] {
                        "0b" => StringUtil::bin_to_dec(&field.as_str()[2..]),
                        "0x" => StringUtil::hex_to_dec(&field.as_str()[2..]),
                        "0d" => StringUtil::dec_to_dec(&field.as_str()[2..]),
                        _ => unreachable!(),
                    };
                    out.push_str(format!("{:0>8b}", dec).as_str());
                }
                // label
                Rule::label => {
                    out.push_str(&format!("{{{}}}", field.as_str())); // placeholder, final pass will substitute PC
                    if labels.get(field.as_str()).is_none() {
                        labels.insert(field.as_str().to_string(), LABEL_NOEXIST);
                    }
                }
                _ => unreachable!(),
            }
            i += 1;
        }

        // add empty instructions. should have inverted the loop object but whatever
        while i < 3 {
            out.push_str("00000000");
            i += 1
        }
    } else {
        println!(
            "unable to find opcode for {} in {lstr}, exiting.",
            first.as_str()
        );

        return Err(ParseError::BadOp);
    }

    // push pending hazards
    for s in pending_w_haz {
        w_hazards.insert(s);
    }
    for s in pending_r_haz {
        r_hazards.insert(s);
    }

    return Ok((out, true, was_branch));
}

#[cfg(test)]
mod tests {
    use super::*;

    // helper
    fn lazy_parse(asm: &str, r: Rule) -> Result<String, ParseError> {
        let mut out = String::with_capacity(8 * 4 + 2);
        let mut pc: u8 = 0;
        let mut labels: HashMap<String, i16> = HashMap::new();

        if r == Rule::line {
            let line = VsisaParser::parse(r, asm)
                .expect("unsuccessful parse")
                .next()
                .unwrap();
            parse_line(line, &mut out, &mut pc, &mut labels)?;
        } else if r == Rule::file {
            let file = VsisaParser::parse(r, asm)
                .expect("unsuccessful parse")
                .next()
                .unwrap();
            for line in file.into_inner() {
                match line.as_rule() {
                    Rule::line => {
                        parse_line(line, &mut out, &mut pc, &mut labels)?;
                    }
                    Rule::EOI => (),
                    _ => unreachable!("{line}"),
                }
            }
        } else {
            assert!(false);
        }
        Ok(out)
    }

    #[test]
    fn basic_lines() -> Result<(), ParseError> {
        let l1 = lazy_parse("ADD r0 r1 r2\n", Rule::line)?;
        assert!(l1.len() == 4 * 8 + 1);

        let l2 = lazy_parse("label:\n", Rule::line)?;
        assert!(l2.len() == 0);

        Ok(())
    }

    #[test]
    fn basic_file() -> Result<(), ParseError> {
        let f1 = lazy_parse("ADD r0 r1 r2\nJMP lab:\nlab:\nMUL r0 r1 r2\n", Rule::file)?;
        println!("{}", f1.len());
        assert!(f1.len() == (4 * 8) * 3 + 1);

        Ok(())
    }
}
