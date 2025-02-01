{
  pkgs ? import <nixpkgs> {},
  fenix ? import <fenix> {},
}: let
  # Helpful nix function
  getLibFolder = pkg: "${pkg}/lib";

  # Rust Toolchain via fenix
  # Fenix will download all nightly toolchain itself
  # You just need to change toolchain.toml for more
  toolchain = fenix.packages.${pkgs.system}.fromToolchainFile {
    file = ./rust-toolchain.toml;

    # Don't worry, if you need sha256 of your toolchain,
    # just run `nix build` and copy paste correct sha256.
    sha256 = "sha256-0Hcko7V5MUtH1RqrOyKQLg0ITjJjtyRPl2P+cJ1p1cY==";
  };
in
  pkgs.stdenv.mkDerivation {
    name = "template-dev";

    # Compile time dependencies
    nativeBuildInputs = with pkgs; [
      # GCC toolchain
      gcc
      gnumake
      pkg-config

      # LLVM toolchain
      cmake
      llvmPackages.llvm
      llvmPackages.clang

      # Hail the Nix
      nixd
      statix
      deadnix
      alejandra

      # Rust
      toolchain
      cargo-watch

      # Other compile time dependencies
      # here
    ];

    # Runtime dependencies which will be shipped
    # with nix package
    buildInputs = with pkgs; [
      # openssl
      # libressl
    ];

    # Set Environment Variables
    RUST_BACKTRACE = "full";

    # Compiler LD variables
    # > Make sure packages have /lib or /include path'es
    NIX_LDFLAGS = "-L${(getLibFolder pkgs.libiconv)}";
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.gcc
      pkgs.libiconv
      pkgs.llvmPackages.llvm
    ];

    shellHook = ''
      # Extra steps
    '';
  }
