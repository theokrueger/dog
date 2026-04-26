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
use std::{collections::HashMap, process};

const LABEL_NOEXIST: i16 = -1; // placeholder value for labels that have not been found yet

#[derive(Debug)]
enum ParseError {
    InvalidLabel,
    BadArg,
    BadOp,
    Hazard,
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
    let mut lstring: String = "".to_string();
    let mut icnt = 0; //
    for line in file.into_inner() {
        if icnt == args.wordlength {
            icnt = 0;
            lstring.push('\n');
            out.push_str(lstring.as_str());
            lstring = "".to_string();
        }
        match line.as_rule() {
            Rule::line => {
                //                if let Err(e) = parse_line(line, &mut out, &mut pc, &mut labels) {
                let was_instruction = parse_line(line, &mut lstring, &mut pc, &mut labels)?;
                icnt += was_instruction as u8;
                //                }
            }
            Rule::EOI => (),
            _ => unreachable!("{line}"),
        }
    }

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
/// Returns whether line was instruction or not
fn parse_line(
    line: Pair<Rule>,
    out: &mut String,
    pc: &mut u8,
    labels: &mut HashMap<String, i16>,
) -> Result<bool, ParseError> {
    let lstr = line.as_str().to_string();
    let mut inr = line.into_inner();
    let len = inr.len();

    if len == 0 {
        // comment or blank
        return Ok(false);
    }

    let first = inr.nth(0).unwrap();
    if len == 1 {
        // must be label
        assert!(first.as_rule() == Rule::label, "error in {lstr}");
        println!("Label '{}' found at pc {pc}", first.as_str());
        labels.insert(first.as_str().to_string(), *pc as i16);
        return Ok(false);
    }
    // otherwise must be instruction
    assert!(first.as_rule() == Rule::instr);
    if let Some(s) = Lut::instr(first.as_str())
        && let Some(restrict) = Lut::instr_restrict(first.as_str())
    {
        out.push_str(*s);

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
                    out.push_str(format!("{:0<8b}", dec).as_str());
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

    *pc += 1;
    return Ok(true);
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
