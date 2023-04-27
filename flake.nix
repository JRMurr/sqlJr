{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    gitignore = {
      url = "github:hercules-ci/gitignore.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay, gitignore, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ (import rust-overlay) (import ./nix/version-overlay.nix) ];
        pkgs = import nixpkgs { inherit system overlays; };
        rustAttrs = import ./nix/rust.nix { inherit pkgs gitignore; };
      in {
        devShells = {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [
              rustAttrs.rust-shell

              napi-rs-cli
              nodejs-18_x

              # common
              watchexec
              just
              nixfmt
            ];
          };
        };
        packages = {
          default = rustAttrs.binary;
          rust-bin = rustAttrs.binary;
          rust-docker = rustAttrs.docker;
        };
      });
}
