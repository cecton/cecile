{
  pkgs ? import <nixpkgs> { },
}:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "cargo-firstpage";
  version = "0.2.3";

  src = pkgs.fetchFromGitHub {
    owner = "cecton";
    repo = "cargo-firstpage";
    rev = "v${version}";
    sha256 = "sha256-4cgSHrqM7zB32v7kECJ6qkbRYsZxU6rFHHGSPkURtnY=";
  };

  cargoHash = "sha256-6TF2X4792cC7PTpduRetQOwrJDhklJ9xSMq/fcE2lCc=";
}
