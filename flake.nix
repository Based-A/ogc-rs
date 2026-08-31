{
  description = "Nix development environment for the ogc-rs crate";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    devkitNix.url = "github:bandithedoge/devkitNix";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    {
      self,
      nixpkgs,
      devkitNix,
      rust-overlay,
      flake-parts
    }@inputs:
      inputs.flake-parts.lib.mkFlake {
        inherit inputs;
      }
      {
        perSystem = {config, system, ...}: {
          devShells =
          let
            pkgs = import inputs.nixpkgs {
              inherit system;
              config = {
                allowUnfree = true;
                allowUnfreePredicate = _: true;
              };
              overlays = [
                inputs.devkitNix.overlays.default
                inputs.rust-overlay.overlays.default
              ];
            };
            rust-nightly = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;
          in
          {
            default = config.devShells.ogc-rs;
            ogc-rs = pkgs.mkShell.override { stdenv = pkgs.devkitNix.stdenvPPC; } {
              buildInputs =
                with pkgs;
                [
                  rust-nightly
                  llvmPackages.libclang
                ];

              LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
            };
          };
      };
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };
}
