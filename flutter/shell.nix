{pkgs ? import <nixpkgs> {}}:
pkgs.mkShell {
  buildInputs = with pkgs; [
    flutter
    pkg-config

    treefmt
    alejandra
    dart
    yamlfmt

    git
  ];

  shellHook = ''
    echo "📱 Flutter development environment"
    echo "Flutter version: $(flutter --version 2>/dev/null | head -1 || echo 'check with: flutter --version')"
    echo ""
    echo "Available commands:"
    echo "  flutter pub get   - Get dependencies"
    echo "  flutter run       - Run app (Linux, Web, or connected device)"
    echo "  flutter build web - Build for web"
    echo "  flutter build linux - Build for Linux desktop"
    echo "  flutter analyze   - Run static analysis"
    echo "  treefmt           - Format all files"
    echo ""
  '';

  # For Linux desktop builds
  LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [
    pkgs.gtk3
    pkgs.libepoxy
  ];
}
