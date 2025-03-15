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
    sha256 = "sha256-AJ6LX/Q/Er9kS15bn9iflkUwcgYqRQxiOIL2ToVAXaU=";
  };

  # Manifest via Cargo.toml
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
      openssl
      # libressl
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
    NIX_LDFLAGS = "-L${(getLibFolder pkgs.libiconv)}";
    LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
      pkgs.gcc
      pkgs.libiconv
      pkgs.llvmPackages.llvm
    ];

    shellHook = ''
      # Load the environment variables from the .env file
      if [ ! -f .env ]; then
      read -r -p "Please enter your telegram bot token: " TELOXIDE_TOKEN;
        echo "export TELOXIDE_TOKEN=$TELOXIDE_TOKEN" > .env;
      else
        source .env;
      fi

      # Set the environment variable
      export TELOXIDE_TOKEN=$TELOXIDE_TOKEN;

      start() {
        # Start watching for changes in the background
        cargo watch -x "run --bin ${manifest.name} -- env" &
        echo
        echo
        echo ===========================================================================
        echo "Press enter to continue on your terminal"
        echo "\> Don't close this terminal as bot is running on watch mode and see log"
        echo "\> Just open your editor from this terminal to make your editor read PATH"
        echo ===========================================================================

        # Store the PID of the background process to file & env
        CARGO_WATCH_PID=$!
        echo "$CARGO_WATCH_PID" > .daemon

        # Function to clean up the background process on exit
        cleanup() {
          kill $CARGO_WATCH_PID || true
          rm -rf ./.daemon
        }

        # Trap EXIT signal to run cleanup function
        trap cleanup EXIT INT TERM
      }

      # Check if there's already session running
      if [ -e ".daemon" ]; then
          echo "There's a session already running..."
          read -p "would you like to stop running instance? (y/n): " answer

          case "$answer" in
              [Yy]*)
                # Read old session file
                _pid=$(<.daemon)

                # Cleanup daemon
                rm -rf ./.daemon

                # Kill & remove old session
                kill $_pid || true
                unset _pid

                # Start the damn bot
                start
                ;;
              [Nn]*)
                echo "Aight, no problem bro. I get you..."
                ;;
              *)
                echo "Invalid input, ignoring running instance"
                ;;
          esac
      else
        # Start the damn bot
        start
      fi
    '';
  }
