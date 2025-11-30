const CHVT: &str = "/usr/bin/chvt";

fn main() -> Result<(), Box<dyn std::error::Error>> {
    std::process::Command::new(CHVT)
        .env_clear()
        .arg("2")
        .status()?;
    std::thread::sleep(std::time::Duration::from_secs(1));
    std::process::Command::new(CHVT)
        .env_clear()
        .arg("1")
        .status()?;
    std::thread::sleep(std::time::Duration::from_secs(1));
    Ok(())
}
