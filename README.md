# Rustyeyes

A small Neovim plugin that turns Cargo's JSON compiler messages into editor diagnostics and a quickfix list. Written in Lua for working on Rust projects.

**Status:** early prototype. Manual checks and optional checks on save; not a replacement for rust-analyzer. It runs Cargo locally, so use it with Rust projects you trust.

## Requirements
- Neovim 0.10 or newer (`vim.system`, `vim.fs.joinpath`).
- Rust and Cargo on PATH. No Lua plugin dependencies.

## Install
With lazy.nvim:
```lua
{
  "joaquincurrais95-eng/rustyeyes",
  config = function()
    require("cargo_diagnostics").setup({ check_on_save = false })
  end,
}
```
Or add this repository to Neovim's runtimepath and call the same setup function.

## Use
Open a saved Rust file inside a Cargo project:
- `:CargoCheck` runs `cargo check --message-format=json`.
- `:CargoBuild` runs `cargo build --message-format=json`.
- `require("cargo_diagnostics").check()` is available for key mappings.
- Set `check_on_save = true` to check Rust buffers after saving.
- Use `:copen` / `:cnext` to inspect compiler messages.

Runs are asynchronous. Starting another run cancels the previous one; corrected diagnostics are removed when the latest run finishes.

## Reproduce a diagnostic
Open `fixtures/demo/src/main.rs`, run `:CargoCheck`, and inspect the intentional type mismatch. Replace `"hello"` with `42`, save and run again: the old diagnostic should disappear. The fixture intentionally does not compile until corrected.

## Design
`Cargo process → line stream → JSON parser → compiler-message router → path/range mapper → diagnostics + quickfix`

The modules under `lua/cargo_diagnostics/` separate process execution, parsing, conversion and editor output. Cargo runs from the nearest manifest directory; Cargo itself resolves workspace membership.

## Tests
From the repository root:
```sh
nvim --headless -u NONE -l tests/run.lua
nvim --headless -u NONE -l tests/integration.lua
```
Tests cover streaming across chunk boundaries, invalid JSON, message filtering, mapping, stale diagnostic cleanup and the public check entry point. CI runs the suite on Linux.

## Current limits
- Diagnostics without file spans are not displayed.
- One active Cargo run per Neovim instance.
- Compiler columns are mapped directly; non-ASCII column offsets need further coverage.
- The demo is a reproducible example, not evidence of a production deployment.
- Windows and complex Rust workspaces need broader integration coverage.

## License
A reuse license has not yet been selected. No LICENSE grant is included.
