//! lookup table for translations of ISA stuff
use phf::phf_map;

/// Instruction translations
static INSTRUCTION_LUT: phf::Map<&'static str, &'static str> = phf_map! {
    "nop" =>  "00000000",
    "add" =>  "00000001",
    "sub" =>  "00000010",
    "mul" =>  "00000011",
    "div" =>  "00000100",
    "jmp" =>  "00000101",
    "jez" =>  "00000110",
    "jgz" =>  "00000111",
    "ladd" => "00001000",
    "lsub" => "00001001",
    "lmul" => "00001010",
    "ldiv" => "00001011",
};

#[derive(PartialEq)]
/// Restriction of arguments by type
pub enum ArgRestrict {
    Empty,
    Reg,
    Lit,
}

use self::ArgRestrict as AR;
/// "Function prototype" for instruction mnemonics or however you spell it
static INSTRUCTION_RESTRICT_LUT: phf::Map<&'static str, &'static [ArgRestrict; 3]> = phf_map! {
    "add" => &[AR::Reg, AR::Reg, AR::Reg],
    "sub" => &[AR::Reg, AR::Reg, AR::Reg],
    "mul" => &[AR::Reg, AR::Reg, AR::Reg],
    "div" => &[AR::Reg, AR::Reg, AR::Reg],
    "jmp" => &[AR::Lit, AR::Empty, AR::Empty],
    "jez" => &[AR::Lit, AR::Reg, AR::Empty],
    "jgz" => &[AR::Lit, AR::Reg, AR::Empty],
    "nop" => &[AR::Empty, AR::Empty, AR::Empty],
    "ladd" => &[AR::Reg, AR::Reg, AR::Lit],
    "lsub" => &[AR::Reg, AR::Reg, AR::Lit],
    "lmul" => &[AR::Reg, AR::Reg, AR::Lit],
    "ldiv" => &[AR::Reg, AR::Reg, AR::Lit],
};

static INSTRUCTION_IS_BRANCH_LUT: phf::Map<&'static str, &'static bool> = phf_map! {
    "jmp" => &true,
    "jez" => &true,
    "jgz" => &true,
};

/// Register translations
static REGISTER_LUT: phf::Map<&'static str, &'static str> = phf_map! {
    "rZ" => "00000000",
    "r0" => "00000010",
    "r1" => "00000011",
    "r2" => "00000100",
    "r3" => "00000101",
    "r4" => "00000110",
    "r5" => "00000111",
    "r6" => "00001000",
};

pub struct Lut;

impl Lut {
    pub fn instr(s: &str) -> Option<&&str> {
        INSTRUCTION_LUT.get(&s.to_lowercase())
    }

    pub fn instr_restrict(s: &str) -> Option<&&[ArgRestrict; 3]> {
        INSTRUCTION_RESTRICT_LUT.get(&s.to_lowercase())
    }

    pub fn reg(s: &str) -> Option<&&str> {
        REGISTER_LUT.get(&s.to_lowercase())
    }

    pub fn is_branch_op(s: &str) -> bool {
        if let Some(_) = INSTRUCTION_IS_BRANCH_LUT.get(&s.to_lowercase()) {
            true
        } else {
            false
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    macro_rules! dupe_check {
        ($map:expr, $type:expr) => {
            for (k1, v1) in $map.entries() {
                for (k2, v2) in $map.entries() {
                    assert!(
                        v1 != v2 || k1 == k2,
                        "'{k1}' and '{k2}' have same {}",
                        $type
                    );
                }
            }
        };
    }

    #[test]
    /// ensure no intersection of addresses between the opcodes. do the sam for addresses
    fn lut_no_dupes() {
        dupe_check!(INSTRUCTION_LUT, "opcode");
        dupe_check!(REGISTER_LUT, "address");
    }

    #[test]
    /// ensure all opcodes have a "function prototype"
    fn lut_arg_has_restrict() {
        for (k1, _) in INSTRUCTION_LUT.entries() {
            println!("{k1}");
            INSTRUCTION_RESTRICT_LUT.get(k1).unwrap();
        }
    }
}
