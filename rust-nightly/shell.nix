# Either have nixpkgs and fenix in your channels
# Or build it using flakes, flake way is more recommended!
flake: {pkgs, ...}: let
  # Hostplatform system
  system = pkgs.hostPlatform.system;

  # Production package
  base = flake.packages.${system}.default;
in
  pkgs.mkShell {
    inputsFrom = [base];

    packages = with pkgs; [
      nixd
      statix
      deadnix
      alejandra

      cargo-watch

      # Other packages here
      # openssl
      # libressl
      # ...
    ];

    # Set Environment Variables
    RUST_BACKTRACE = "full";

    shellHook = ''
      # Extra steps to do while activating development shell
    '';
  }
