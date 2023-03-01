#![allow(clippy::unreadable_literal)]

use crypto::hmac::Hmac;
use crypto::mac::Mac;
use crypto::sha1::Sha1;
use serde::Deserialize;
use std::time::{SystemTime, UNIX_EPOCH};

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct Entry {
    algo: String,
    counter: u64,
    digits: u32,
    #[serde(default)]
    issuer_ext: String,
    #[serde(default)]
    issuer_int: String,
    #[serde(default)]
    issuer_alt: String,
    label: String,
    period: u64,
    secret: Vec<i8>,
    type_: String,
}

impl Entry {
    fn issuer(&self) -> &str {
        if !self.issuer_alt.is_empty() {
            &self.issuer_alt
        } else if !self.issuer_int.is_empty() {
            &self.issuer_int
        } else if !self.issuer_ext.is_empty() {
            &self.issuer_ext
        } else {
            "n/a"
        }
    }
}

#[derive(Debug, Deserialize)]
#[serde(rename_all = "camelCase")]
struct TokensJson {
    token_order: Vec<String>,
    tokens: Vec<Entry>,
}

fn main() {
    let file = std::env::args().last().unwrap();
    let file = std::fs::File::open(file).unwrap();
    let file = std::io::BufReader::new(file);

    let tokens: TokensJson = serde_json::from_reader(file).unwrap();

    let start = SystemTime::now();
    let since_the_epoch = start
        .duration_since(UNIX_EPOCH)
        .expect("Time went backwards");

    for token in &tokens.tokens {
        let secret: Vec<u8> = token
            .secret
            .iter()
            .map(|&x| if x < 0 { 255 - (-x) as u8 + 1 } else { x as u8 })
            .collect();
        let secret = generate(
            since_the_epoch.as_secs() + 5,
            secret.as_slice(),
            token.period,
            token.digits,
        );
        println!("{}: {}", token.issuer(), secret);
    }
}

fn generate(epoch: u64, secret: &[u8], period: u64, digits: u32) -> String {
    let counter = (epoch / period) as u64;

    let div = 10_u32.pow(digits);

    let mut mac = Hmac::new(Sha1::new(), secret);
    mac.input(&counter.to_be_bytes());
    let result = mac.result();
    let digest = result.code().to_owned();
    //eprintln!("{:?}", digest);

    use std::convert::TryInto;
    let hash_len = digest.len();
    //println!("len: {}", hash_len);
    let off2 = u8::from_be_bytes(digest[19..].try_into().unwrap()) & 0xf;
    //println!("off2: {}", off2);
    let int_hash = u32::from_be_bytes(
        digest[off2 as usize..(off2 as usize + 4)]
            .try_into()
            .unwrap(),
    );
    //println!("int hash: {:064b}", int_hash);
    let lsb31 = int_hash & 0x7FFFFFFF;
    let hotp = format!("{:06}", lsb31 % div as u32);

    /*
    let off = (digest[digest.len() - 1] & 0xf) as usize;
    let mut bin: u32 = ((digest[off] & 0x7f) as u32) << 0x18;
    bin |= ((digest[off + 1]) as u32) << 0x10;
    bin |= ((digest[off + 2]) as u32) << 0x08;
    bin |= (digest[off + 3]) as u32;

    bin %= div;
    let hotp = format!("{:06}", bin);
    */

    //eprintln!("off={} {}", off, off2);
    //eprintln!("totp={} {}", hotp, totp);

    hotp
}

#[cfg(test)]
mod tests {
    #[test]
    fn generate_code() {
        let secret = base32::decode(
            base32::Alphabet::RFC4648 { padding: true },
            "BASE32SECRET2345AB",
        )
        .expect("valid base32");

        assert_eq!(
            super::generate(1535317397, secret.as_slice(), 30, 6),
            "280672"
        );
        assert_eq!(
            super::generate(1535317427, secret.as_slice(), 30, 6),
            "757502"
        );
        assert_eq!(
            super::generate(1535317457, secret.as_slice(), 30, 6),
            "154326"
        );
        assert_eq!(
            super::generate(1535317487, secret.as_slice(), 30, 6),
            "240371"
        );
    }
}
