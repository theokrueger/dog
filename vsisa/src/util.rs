pub struct StringUtil {}

impl StringUtil {
    pub fn bin_to_dec(s: &str) -> u8 {
        let n = u8::from_str_radix(s, 2).expect("Tried converting a non-binary number!");
        println!("Literal Binary {s} -> {n}");
        return n;
    }

    pub fn hex_to_dec(s: &str) -> u8 {
        let n = u8::from_str_radix(s, 16).expect("Tried converting a non-binary number!");
        println!("Literal Hex {s} -> {n}");
        return n;
    }

    pub fn dec_to_dec(s: &str) -> u8 {
        let n = u8::from_str_radix(s, 10).expect("Tried converting a non-binary number!");
        println!("Literal Decimal {s} -> {n}");
        return n;
    }
}
