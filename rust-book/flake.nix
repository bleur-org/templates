{
  description = "Rust book template written by Uzbek L10N (@uzbek-net)";

  # inputs are other flakes you use within your own flake, dependencies
  # for your flake, etc.
  inputs = {
    # Stable Nixpkgs
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    # Unstable Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Also see the 'unstable-packages' overlay at 'overlays/home.nix'.

    # Flake utils for eachSystem
    flake-utils.url = "github:numtide/flake-utils";
  };

  # In this context, outputs are mostly about getting home-manager what it
  # needs since it will be the one using the flake
  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  } @ inputs: let
    # Self instance pointer
    outputs = self;
  in
    # Attributes for each system
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        # Nix formatter
        formatter = pkgs.alejandra;

        # Development shells
        devShells.default = import ./shell.nix {inherit pkgs;};
      }
    );
}