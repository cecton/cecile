{
  inputs = {
    nixpkgs.url      = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url  = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, rust-overlay, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs { inherit system overlays; };

        rustToolchain = pkgs.rust-bin.stable.latest.default.override {
          extensions = [ "rust-src" "clippy" "rustfmt" "rust-analyzer" ];
          targets = [ "wasm32-unknown-unknown" "x86_64-unknown-linux-musl" ];
        };

        muslCc = pkgs.pkgsCross.musl64.stdenv.cc;

        nativeDeps = with pkgs; [ pkg-config ] ++ [ muslCc ];
        runtimeDeps = with pkgs; [
          libx11
          libxcursor
          libxrandr
          libxi
          libxkbcommon
          wayland
          vulkan-loader
          mesa
          libGL
          openssl
        ];

      in {
        devShells.default = pkgs.mkShell {
          buildInputs = [ rustToolchain ] ++ nativeDeps ++ runtimeDeps;

          shellHook = ''
            export LD_LIBRARY_PATH=${pkgs.lib.makeLibraryPath runtimeDeps}:$LD_LIBRARY_PATH
            export CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_LINKER=${muslCc}/bin/x86_64-unknown-linux-musl-gcc
            export CC_x86_64_unknown_linux_musl=${muslCc}/bin/x86_64-unknown-linux-musl-gcc
            export CXX_x86_64_unknown_linux_musl=${muslCc}/bin/x86_64-unknown-linux-musl-g++
            export CARGO_TARGET_X86_64_UNKNOWN_LINUX_MUSL_RUSTFLAGS="-C target-feature=+crt-static"
          '';
        };
      }
    );
}
