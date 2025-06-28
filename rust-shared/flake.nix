{
  description = "A beginning of an awesome project bootstrapped with github:bleur-org/templates";

  inputs = {
    # Stable for keeping thins clean
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";

    # Fresh and new for testing
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    # The flake-utils library
    flake-utils.url = "github:numtide/flake-utils";

    # Rust toolchain shit
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    fenix,
    ...
  } @ inputs:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [fenix.overlays.default];
      };
    in {
      # Nix script formatter
      formatter = pkgs.alejandra;

      # Development environment
      devShells.default = import ./shell.nix {inherit pkgs fenix;};

      # Output package
      packages.default = pkgs.callPackage ./. {inherit pkgs fenix;};
    });
}
