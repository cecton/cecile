{
  inputs.fenix.url = "github:nix-community/fenix";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs";

  outputs = { self, nixpkgs, fenix, ... }:
  let
    pkgs = import nixpkgs { system = "x86_64-linux"; };
    toolchain = fenix.packages.${pkgs.system}.fromToolchainFile {
      file = ./rust-toolchain.toml;
      sha256 = "sha256-SJwZ8g0zF2WrKDVmHrVG3pD2RGoQeo24MEXnNx5FyuI=";
    };
  in {
    devShells.${pkgs.system}.default = pkgs.mkShell {
      nativeBuildInputs = [
        toolchain
        pkgs.openssl
      ];

      shellHook = ''
        export LIBCLANG_PATH=${pkgs.llvmPackages.libclang.lib}/lib
        export OPENSSL_DIR=${pkgs.openssl.dev}
        export OPENSSL_LIB_DIR=${pkgs.openssl.out}/lib
        export OPENSSL_INCLUDE_DIR=${pkgs.openssl.dev}/include
      '';
    };
  };
}
