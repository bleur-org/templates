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
    glibc
    sysprof
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
        llvmPackages.llvm
        llvmPackages.clang-tools
        pkg-config
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

    meta = with lib; {
      homepage = "https://github.com/bleur-org/templates";
      description = "An example C/GTK template made by Bleur developers.";
      licencse = licenses.bsd2;
      platforms = with platforms; linux ++ darwin;
      maintainers = [maintainers.orzklv];
    };
  }
