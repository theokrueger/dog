mod args;
use args::Args;
mod lut;
use lut::{ArgRestrict, Lut};
mod parse;
use parse::{Rule, VsisaParser};

use clap::Parser as ClapParser;
use pest::{Parser as PestParser, iterators::Pair};
use std::{collections::HashMap, process};

fn main() {
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
    let mut labels: HashMap<String, u8> = HashMap::new(); // store program counter of label
    for line in file.into_inner() {
        match line.as_rule() {
            Rule::line => {
                parse_line(line, &mut out, &mut pc, &mut labels);
            }
            Rule::EOI => (),
            _ => unreachable!("{line}"),
        }
    }

    // write
    args.write(out);
}

fn parse_line(line: Pair<Rule>, out: &mut String, pc: &mut u8, labels: &mut HashMap<String, u8>) {
    let lstr = line.as_str().to_string();
    let mut inr = line.into_inner();
    let len = inr.len();

    if len == 0 {
        // comment or blank
        return;
    }

    let first = inr.nth(0).unwrap();
    if len == 1 {
        // must be label
        assert!(first.as_rule() == Rule::label, "error in {lstr}");
        println!("Label '{}' found at pc {pc}", first.as_str());
        labels.insert(first.as_str().to_string(), *pc);
        return;
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
                    "invalid argument type of {} to {} in {lstr}, exiting.",
                    field.as_str(),
                    first.as_str()
                );
                process::exit(1);
            }

            // resolve argument
            match field.as_rule() {
                // register
                Rule::reg => {
                    if let Some(r) = Lut::reg(field.as_str()) {
                        out.push_str(*r);
                    } else {
                        println!("invalid register {} in {lstr}, exiting.", field.as_str(),);
                        process::exit(1);
                    }
                }
                // literal
                Rule::literal => {
                    let dec = match &field.as_str()[..2] {
                        "0b" => 12,
                        "0x" => 13,
                        "0d" => 14,
                        _ => unreachable!(),
                    };
                    out.push_str(format!("{:0<8b}", dec).as_str());
                }
                // label
                Rule::label => {
                    if let Some(l) = labels.get(field.as_str()) {
                        out.push_str(format!("{:0<8b}", l).as_str());
                    } else {
                        println!("invalid label {} in {lstr}, exiting.", field.as_str(),);
                        process::exit(1);
                    }
                }
                _ => unreachable!(),
            }
            i += 1;
        }

        // zero-pad
        while i < 4 {
            out.push_str("00000000");
            i += 1
        }
    } else {
        println!(
            "unable to find opcode for {} in {lstr}, exiting.",
            first.as_str()
        );
        process::exit(1);
    }

    *pc += 1;
    out.push('\n');
}

#[cfg(test)]
mod tests {
    use super::*;

    fn lazy_line(asm: &str) -> String {
        let mut out = String::with_capacity(256);
        let mut pc: u8 = 0; // program counter
        let mut labels: HashMap<String, u8> = HashMap::new(); // store program counter of label

        let line = VsisaParser::parse(Rule::line, asm)
            .expect("unsuccessful parse")
            .next()
            .unwrap();
        parse_line(line, &mut out, &mut pc, &mut labels);
        return out;
    }

    #[test]
    fn basic_lines() {
        let l1 = lazy_line("ADD r0 r1 r2\n");
        assert!(l1.len() == 4 * 8 + 1);

        let l2 = lazy_line("label:\n");
        assert!(l2.len() == 0);
    }
}
