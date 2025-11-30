const FGCONSOLE: &str = "/usr/bin/fgconsole";
const CHVT: &str = "/usr/bin/chvt";

use std::process::Command;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let fgconsole = Command::new(FGCONSOLE).env_clear().output()?;
    let vt = match fgconsole.stdout.as_slice().trim_ascii_end() {
        b"1" => "4",
        _ => "1",
    };
    Command::new(CHVT).env_clear().arg(vt).status()?;
    Ok(())
}
