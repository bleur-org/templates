{
  pkgs ? import <nixpkgs> {},
  fenix ? import <fenix> {},
}: let
  # Helpful nix function
  getLibFolder = pkg: "${pkg}/lib";

  # Rust Toolchain via fenix
  toolchain = fenix.packages.${pkgs.system}.fromToolchainFile {
    file = ./rust-toolchain.toml;

    # Don't worry, if you need sha256 of your toolchain,
    # just run `nix build` and copy paste correct sha256.
    sha256 = "sha256-Hn2uaQzRLidAWpfmRwSRdImifGUCAb9HeAqTYFXWeQk=";
  };

  # Manifest via Cargo.toml
  manifest = (pkgs.lib.importTOML ./Cargo.toml).workspace.package;
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

      # Rust
      toolchain
      cargo-watch

      # Databases & ORM
      postgresql
      diesel-cli
      diesel-cli-ext

      # A few utils
      just
    ];

    # Runtime dependencies which will be shipped
    # with nix package
    buildInputs = with pkgs; [
      openssl
      # libressl
    ];

    # Set Environment Variables
    RUST_BACKTRACE = "full";

    # Compiler LD variables
    # > Make sure packages have /lib or /include path'es
    NIX_LDFLAGS = "-L${(getLibFolder pkgs.libiconv)} -L${getLibFolder pkgs.postgresql}";
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.gcc
      pkgs.libiconv
      pkgs.postgresql
      pkgs.llvmPackages.llvm
    ];

    shellHook = ''
      source ./.github/scripts/init-db.sh
      source ./.github/scripts/init-service.sh
    '';

    ####################################################################
    # Without  this, almost  everything  fails with  locale issues  when
    # using `nix-shell --pure` (at least on NixOS).
    # See
    # + https://github.com/NixOS/nix/issues/318#issuecomment-52986702
    # + http://lists.linuxfromscratch.org/pipermail/lfs-support/2004-June/023900.html
    ####################################################################

    LOCALE_ARCHIVE =
      if pkgs.stdenv.isLinux
      then "${pkgs.glibcLocales}/lib/locale/locale-archive"
      else "";
  }
