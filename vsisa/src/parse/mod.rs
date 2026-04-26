use pest_derive::Parser;

#[derive(Parser)]
#[grammar = "parse/vsisa.pest"]
pub struct VsisaParser;

#[cfg(test)]
mod tests {
    use super::*;
    use pest::error::Error as PestError;

    #[test]
    fn parse_special() -> Result<(), PestError<Rule>> {
        // whitespace
        VsisaParser::parse(Rule::WHITESPACE, " ")?;
        VsisaParser::parse(Rule::WHITESPACE, "\t")?;
        VsisaParser::parse(Rule::WHITESPACE, "   \t   \t")?;
        VsisaParser::parse(Rule::WHITESPACE, "").err().unwrap();
        VsisaParser::parse(Rule::WHITESPACE, "asdfaf")
            .err()
            .unwrap();

        // comment
        VsisaParser::parse(Rule::COMMENT, "// this is a comment")?;
        VsisaParser::parse(Rule::COMMENT, "/* this is a block comment */")?;
        VsisaParser::parse(
            Rule::COMMENT,
            "/* this is a multiline
                block comment */",
        )?;
        VsisaParser::parse(Rule::COMMENT, "").err().unwrap();
        VsisaParser::parse(Rule::COMMENT, "not a comment")
            .err()
            .unwrap();

        Ok(())
    }

    #[test]
    fn parse_atomics() -> Result<(), PestError<Rule>> {
        // literals
        VsisaParser::parse(Rule::bin, "0b01010010")?;
        VsisaParser::parse(Rule::bin, "0b2345").err().unwrap();
        VsisaParser::parse(Rule::bin, "01000100").err().unwrap();

        VsisaParser::parse(Rule::hex, "0x0123456789abcdef")?;
        VsisaParser::parse(Rule::hex, "0xABCDEFabcdef01234567890")?;
        VsisaParser::parse(Rule::hex, "0xGg").err().unwrap();
        VsisaParser::parse(Rule::hex, "0Ga2394").err().unwrap();

        VsisaParser::parse(Rule::dec, "0d1234567890")?;
        VsisaParser::parse(Rule::dec, "0dA").err().unwrap();

        // registers
        VsisaParser::parse(Rule::reg, "r0")?;
        VsisaParser::parse(Rule::reg, "reg2").err().unwrap();

        // instructions
        VsisaParser::parse(Rule::instr, "ADD")?;
        VsisaParser::parse(Rule::instr, "SUB")?;
        VsisaParser::parse(Rule::instr, "D1V").err().unwrap();

        // labels
        VsisaParser::parse(Rule::label, "label:")?;
        VsisaParser::parse(Rule::label, "this_is_a_label:")?;
        VsisaParser::parse(Rule::label, "not :").err().unwrap();

        Ok(())
    }

    #[test]
    fn parse_line() -> Result<(), PestError<Rule>> {
        VsisaParser::parse(Rule::line, "MULT\n").err().unwrap();
        VsisaParser::parse(Rule::line, "MULT 0x234\n")
            .err()
            .unwrap();
        VsisaParser::parse(Rule::line, "ADD 0b01AA").err().unwrap();
        VsisaParser::parse(Rule::line, "MULT 0x2 0b1 0d3 r2 r4\n")
            .err()
            .unwrap();
        VsisaParser::parse(Rule::line, "label: r0\n").err().unwrap();
        VsisaParser::parse(Rule::line, "SUB r2 r2 r4\n")?;
        VsisaParser::parse(Rule::line, "JMP \t\t\t     /*// */r0\n")?;
        VsisaParser::parse(Rule::line, "MUL r0 0d2  // comment \n")?;
        VsisaParser::parse(Rule::line, "label: // comment \n")?;
        VsisaParser::parse(Rule::line, "// comment \n")?;
        VsisaParser::parse(Rule::line, "/* comment2 */ \n")?;
        VsisaParser::parse(
            Rule::line,
            "ADD r0 0b000 0x1234 /*wtf am i doing here */ \n",
        )?;

        Ok(())
    }
}
