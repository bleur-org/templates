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
}: let
  # Helpful nix function
  lib = pkgs.lib;
  getLibFolder = pkg: "${pkg}/lib";

  # Manifest via Cargo.toml
  manifest = (pkgs.lib.importTOML ./Cargo.toml).workspace.package;
in
  pkgs.rustPlatform.buildRustPackage {
    # Package related things automatically
    # obtained from Cargo.toml, so you don't
    # have to do everything manually
    pname = manifest.name;
    version = manifest.version;

    # Your govnocodes
    src = pkgs.lib.cleanSource ./.;

    cargoLock = {
      lockFile = ./Cargo.lock;
      # Use this if you have dependencies from git instead
      # of crates.io in your Cargo.toml
      # outputHashes = {
      #   # Sha256 of the git repository, doesn't matter if it's monorepo
      #   "example-0.1.0" = "sha256-80EwvwMPY+rYyti8DMG4hGEpz/8Pya5TGjsbOBF0P0c=";
      # };
    };

    # Compile time dependencies
    nativeBuildInputs = with pkgs; [
      # Other compile time dependencies
      postgresql
    ];

    # Runtime dependencies which will be shipped
    # with nix package
    buildInputs = with pkgs; [
      openssl
      # libressl
    ];

    fixupPhase = ''
      mkdir -p $out/mgrs
      cp -R ./crates/database/* $out/mgrs
    '';

    # Set Environment Variables
    RUST_BACKTRACE = 1;
    RUST_SRC_PATH = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";

    # Compiler LD variables
    NIX_LDFLAGS = "-L${(getLibFolder pkgs.libiconv)} -L${(getLibFolder pkgs.postgresql)}";
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.libiconv
      pkgs.postgresql
    ];

    meta = with lib; {
      homepage = manifest.homepage;
      description = manifest.description;
      # https://github.com/NixOS/nixpkgs/blob/master/lib/licenses.nix
      license = with lib.licenses; [asl20 mit];
      platforms = with platforms; linux ++ darwin;
      mainProgram = "server";
      maintainers = [lib.maintainers.orzklv];
    };
  }
