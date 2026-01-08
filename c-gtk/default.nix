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
in
  pkgs.llvmPackages.stdenv.mkDerivation rec {
    pname = "example";
    version = "0.0.1";

    src = ./.;

    nativeBuildInputs = with pkgs; [
      # LLVM toolchain
      cmake
      llvmPackages.llvm
      llvmPackages.clang-tools

      # GTK toolchain
      gtk4
    ];

    cmakeFlags = [
      "-DENABLE_TESTING=OFF"
      "-DENABLE_INSTALL=ON"
    ];

    # Necessary Environment Variables
    # NIX_LIBSABINE_HEADER = "${libsabine}/include";
    # NIX_LDFLAGS = "-L${getLibrary libsabine}";
    # LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
    #   libsabine
    # ];

    meta = with lib; {
      homepage = "https://github.com/bleur-org/templates";
      description = "An example C/GTK template made by Bleur developers.";
      licencse = licenses.bsd2;
      platforms = with platforms; linux ++ darwin;
      maintainers = [maintainers.orzklv];
    };
  }
