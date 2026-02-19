use clap::Parser;
use std::{fs, io::Error as IoError, path::PathBuf};

/// assembler for very-short-ISA
#[derive(Parser, Debug)]
#[command(version, about, long_about = None)]
pub struct Args {
    /// input asm file
    in_file: PathBuf,

    /// output binary file
    out_file: PathBuf,
}

impl Args {
    pub fn read(&self) -> String {
        fs::read_to_string(self.in_file.clone()).expect("unable to read in_file")
    }

    pub fn write(&self, s: String) {
        fs::write(self.out_file.clone(), s).expect("unable to write to out_file")
    }
}
