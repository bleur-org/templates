{
  pkgs ? let
    lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
    nixpkgs = fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
      sha256 = lock.narHash;
    };
  in
    import nixpkgs {overlays = [];},
  ...
}:
pkgs.mkShell {
  name = "templates-shell";

  packages = with pkgs; [
    # Nix
    nixd
    statix
    deadnix
    alejandra

    # TOML
    just-lsp
    taplo-lsp
  ];

  NIX_CONFIG = "extra-experimental-features = nix-command flakes";
}
