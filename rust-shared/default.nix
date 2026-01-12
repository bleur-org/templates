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
  ...
}: let
  # Helpful nix function
  lib = pkgs.lib;
  # getLibFolder = pkg: "${pkg}/lib"; # uncomment for LDs

  # Contents of Cargo.toml
  toml = pkgs.lib.importTOML ./Cargo.toml;

  # Manifest via Cargo.toml
  manifest = toml.package;

  # Rust Toolchain via fenix
  toolchain = pkgs.fenix.fromToolchainFile {
    file = ./rust-toolchain.toml;

    # Don't worry, if you need sha256 of your toolchain,
    # just run `nix build` and copy paste correct sha256.
    sha256 = "sha256-Hn2uaQzRLidAWpfmRwSRdImifGUCAb9HeAqTYFXWeQk=";
  };
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
      # Rust
      toolchain

      # Other compile time dependencies
      # here
      # pkg-config
      # openssl
    ];

    # Runtime dependencies which will be shipped
    # with nix package
    buildInputs = with pkgs; [
      # openssl
      # libressl
    ];

    postInstall = ''
      mkdir -p $out/include

      # Make sure, your header file has the
      # same name as the name in your Cargo.toml
      cp ./${toml.lib.name}.h $out/include/
    '';

    # Set Environment Variables
    RUST_BACKTRACE = 1;

    # => Use this only if you know what you're doing, else remove!
    # NIX_LDFLAGS = "-L${(getLibFolder pkgs.libiconv)}";
    # LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
    #   pkgs.libiconv
    # ];

    meta = with lib; {
      homepage = manifest.homepage;
      description = manifest.description;
      # https://github.com/NixOS/nixpkgs/blob/master/lib/licenses.nix
      license = with licenses; [mit];
      platforms = with platforms; linux ++ darwin;
      maintainers = with maintainers; [orklzv];
    };
  }
