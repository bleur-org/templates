{
  description = "React + TypeScript + Vite development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    treefmt-nix.url = "github:numtide/treefmt-nix";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    treefmt-nix,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = nixpkgs.legacyPackages.${system};

        treefmtEval = treefmt-nix.lib.evalModule pkgs {
          projectRootFile = "flake.nix";
          programs.alejandra.enable = true;
          programs.prettier.enable = true;
          programs.eslint.enable = true;

          settings.formatter.prettier.excludes = [
            "pnpm-lock.yaml"
            "*.svg"
          ];
        };
      in {
        devShells.default = import ./shell.nix {inherit pkgs;};

        formatter = treefmtEval.config.build.wrapper;

        checks.formatting = treefmtEval.config.build.check self;
      }
    );
}
