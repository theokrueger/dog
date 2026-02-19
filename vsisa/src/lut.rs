use phf::phf_map;

static INSTRUCTION_LUT: phf::Map<&'static str, &'static str> = phf_map! {
    "add" => "00000001",
    "sub" => "00000002",
    "mul" => "00000003",
    "div" => "00000004",
    "jmp" => "00000005",
    "jez" => "00000006",
    "jgt" => "00000007",
    "nop" => "00000008",
};

#[derive(PartialEq)]
pub enum ArgRestrict {
    Empty,
    Reg,
    Lit,
}

use self::ArgRestrict as AR;
static INSTRUCTION_RESTRICT_LUT: phf::Map<&'static str, &'static [ArgRestrict; 3]> = phf_map! {
    "add" => &[AR::Reg, AR::Reg, AR::Reg],
    "sub" => &[AR::Reg, AR::Reg, AR::Reg],
    "mul" => &[AR::Reg, AR::Reg, AR::Reg],
    "div" => &[AR::Reg, AR::Reg, AR::Reg],
    "jmp" => &[AR::Reg, AR::Empty, AR::Empty],
    "jez" => &[AR::Lit, AR::Reg, AR::Empty],
    "jgt" => &[AR::Lit, AR::Reg, AR::Empty],
    "nop" => &[AR::Empty, AR::Empty, AR::Empty],
};

static REGISTER_LUT: phf::Map<&'static str, &'static str> = phf_map! {
    "r0" => "00000001",
    "r1" => "00000002",
    "r2" => "00000003",
    "r3" => "00000004",
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
    fn lut_no_dupes() {
        dupe_check!(INSTRUCTION_LUT, "opcode");
        dupe_check!(REGISTER_LUT, "address");
    }

    #[test]
    fn lut_arg_has_restrict() {
        for (k1, _) in INSTRUCTION_LUT.entries() {
            println!("{k1}");
            INSTRUCTION_RESTRICT_LUT.get(k1).unwrap();
        }
    }
}
