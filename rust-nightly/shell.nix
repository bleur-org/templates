# Either have nixpkgs and fenix in your channels
# Or build it using flakes, flake way is more recommended!
{
  pkgs ? let
    lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
    nixpkgs = fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
      sha256 = lock.narHash;
    };
  in
    import nixpkgs {overlays = [(import "${fetchTarball "https://github.com/nix-community/fenix/archive/main.tar.gz"}/overlay.nix")];},
}: let
  # Helpful nix function
  getLibFolder = pkg: "${pkg}/lib";

  # Rust Toolchain via fenix
  # Fenix will download all nightly toolchain itself
  # You just need to change toolchain.toml for more
  toolchain = pkgs.fenix.fromToolchainFile {
    file = ./rust-toolchain.toml;

    # Don't worry, if you need sha256 of your toolchain,
    # just run `nix build` and copy paste correct sha256.
    sha256 = "sha256-0Hcko7V5MUtH1RqrOyKQLg0ITjJjtyRPl2P+cJ1p1cY==";
  };

  # Manifest
  manifest = (pkgs.lib.importTOML ./Cargo.toml).package;
in
  pkgs.stdenv.mkDerivation {
    name = "${manifest.name}-dev";

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
