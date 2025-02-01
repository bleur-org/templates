{
  description = "Templates for various development projects";

  inputs = {
    # Too old to work with most libraries
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    # Perfect!
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    # The flake-utils library
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    ...
  }:
    flake-utils.lib.eachDefaultSystem
    (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        # Nix script formatter
        formatter = pkgs.alejandra;

        # Development environment
        devShells.default = import ./shell.nix {inherit pkgs;};
      }
    )
    // {
      # All templates
      templates = {
        rust = {
          path = ./rust;
          description = "Typical Rust project template using fenix";
          welcomeText = ''
            # Simple Rust Nix template by Xinux community
            ## Intended usage
            The intended usage of this flake is to write a project on Rust which compiles to an executable project

            ## Important
            Please, after bootstrapping your own project, don't forget to read readme.md for more infomration on usage.

            ## More info
            - [Rust language](https://rust-lang.org)
            - [Ruby in the NixOS manual](https://nixos.org/manual/nixpkgs/stable/#rust)
            - [Rust NixOS Wiki](https://nixos.wiki/wiki/Rust)
            - [Fenix for Nix](https://github.com/nix-community/fenix)
          '';
        };
        # rust-nightly = {
        #   path = ./rust-nightly;
        #   description = "Nightly Rust project template using fenix";
        # };
      };
    };
}
