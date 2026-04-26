use clap::Parser;
use std::{fs, path::PathBuf};

/// assembler for very-short-ISA
#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
pub struct Args {
    /// input asm file
    in_file: PathBuf,

    /// output binary file
    out_file: PathBuf,

    /// Wordlength in untils of instructions
    #[arg(short, long, default_value_t = 1)]
    pub wordlength: u8,
}

impl Args {
    pub fn read(&self) -> String {
        fs::read_to_string(self.in_file.clone()).expect("unable to read in_file")
    }

    pub fn write(&self, s: String) {
        fs::write(self.out_file.clone(), s).expect("unable to write to out_file")
    }
}
