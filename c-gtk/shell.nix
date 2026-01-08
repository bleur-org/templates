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
in
  pkgs.stdenv.mkDerivation {
    name = "example-shell";

    nativeBuildInputs = with pkgs; [
      # LLVM & Clang toolchain
      cmake
      cmake-format
      llvmPackages.llvm
      llvmPackages.clang-tools

      # Hail the Nix
      nixd
      statix
      deadnix
      alejandra

      # Launch scripts
      just
      just-lsp
    ];

    # Necessary Environment Variables
    # NIX_LIBSABINE_HEADER="${libsabine}/include";
    NIX_LDFLAGS = with pkgs; "-L${getLibrary gtk4}";
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (with pkgs; [
      gtk4
    ]);

    # Some dev env bootstrap scripts # yellow = 3; blue = 4
    shellHook = ''
      echo "$(tput rev)$(tput setaf 4)You're in LLVM nix shell environment...$(tput sgr0)"

      source ${./.github/scripts/log.sh}

      bootstrap () {
        local _cwp="$(pwd)"
        local _build="$(pwd)/build"

        log "warn" "let's see if build folder is fine..."

        if [ -d "$_build" ]; then
          log "trace" "seems like everything lookin' fine here..."

          return
        fi

        if [ ! -d "$_build" ]; then
          log "warn" "boostrapping build directory..."
          mkdir -p $_build

          # Enter build folder
          cd $_build

          # Bootstrap cmake
          cmake -DCMAKE_EXPORT_COMPILE_COMMANDS=ON ..

          # Return back
          cd $_cwp
        fi

        return
      }

      bootstrap
    '';
  }
