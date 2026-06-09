---
name: rust
description: when working on a Rust project
---

## Before committing any changes in a Rust project

1. Run `cargo fmt` to format all code
2. Verify it succeeds before staging files
3. NEVER ever install rustup or run rustup command

## When writing code

When a function accepts a byte index representing a character position, assume
the index is aligned to a UTF-8 character boundary.
