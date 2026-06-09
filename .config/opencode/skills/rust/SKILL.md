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

### No magic sentinel values

Never encode "invalid" or "absent" state by stuffing a sentinel number (e.g.
`-1`) into a field that normally holds real data. This is a common slope AI
pattern and it is broken by design: sentinels are invisible to downstream code
- clamps, casts, arithmetic, and comparisons all treat them as ordinary
values, creating hidden coupling between producer and every consumer. Use
`Option<T>` or a dedicated `enum` variant instead.
