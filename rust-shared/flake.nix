{
  description = "A Rust project bootstrapped with github:xinux-org/templates";

  inputs = {
    # Stable for keeping thins clean
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

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
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      # Nix script formatter
      formatter = pkgs.alejandra;

      # Development environment
      devShells.default = import ./shell.nix {inherit pkgs fenix;};

      # Output package
      packages.default = pkgs.callPackage ./. {inherit pkgs fenix;};
    });
}
