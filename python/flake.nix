{
  description = "Basic Python template with UV";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = {
    self,
    nixpkgs,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} (top @ {...}: {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      perSystem = {pkgs, ...}: {
        formatter = pkgs.alejandra;

        devShells.default = import ./shell.nix {inherit pkgs;};

        # packages.default = pkgs.callPackage ./. {inherit pkgs;};
      };
    });
}
