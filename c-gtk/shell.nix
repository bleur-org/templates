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
  # For extension
  inherit (pkgs) lib;

  # Helpful nix function
  getLibrary = pkg: "${pkg}/lib";

  # Shareables + includables
  programs = with pkgs; [
    gtk4
    # glibc
    # sysprof
  ];
in
  pkgs.llvmPackages.stdenv.mkDerivation rec {
    pname = "cgtk";
    version = "0.0.1";

    src = ./.;

    nativeBuildInputs =
      (with pkgs; [
        # LLVM toolchain
        cmake
        cmake-format
        llvmPackages.llvm
        llvmPackages.clang-tools
        pkg-config

        # Hail the Nix
        nixd
        statix
        deadnix
        alejandra

        # Launch scripts
        just
        just-lsp
      ])
      ++ programs;

    cmakeFlags = [
      "-DENABLE_TESTING=OFF"
      "-DENABLE_INSTALL=ON"
      "-DPKG_CONFIG_EXECUTABLE=${lib.getExe pkgs.pkg-config}"
    ];

    # Necessary Environment Variables
    INCLUDE = lib.makeIncludePath programs;
    NIX_LDFLAGS = with pkgs; "-L${getLibrary gtk4}";
    LD_LIBRARY_PATH = lib.makeLibraryPath programs;
    PKG_CONFIG_EXECUTABLE = lib.getExe pkgs.pkg-config;

    # Some dev env bootstrap scripts # yellow = 3; blue = 4
    shellHook = ''
      echo "$(tput rev)$(tput setaf 4)You're in LLVM nix shell environment...$(tput sgr0)"

      source ${./.github/scripts/log.sh}
      source ${./.github/scripts/bootstrap.sh}
    '';
  }
