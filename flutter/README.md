# Flutter + Nix Template

A Flutter project template with a reproducible Nix development environment.

## Prerequisites

- [Nix](https://nixos.org/download.html) with flakes enabled
- [direnv](https://direnv.net/) (optional but recommended)

## Getting Started

### 1. Enter the development environment

With direnv (automatic):

```bash
direnv allow
```

Without direnv (manual):

```bash
nix develop
```

This will set up Flutter, Dart, and development tooling automatically.

## Available Commands

| Command | Description |
|---------|-------------|
| `flutter pub get` | Install dependencies |
| `flutter run` | Run app (Linux, Web, or connected device) |
| `flutter build web` | Build for web |
| `flutter build linux` | Build for Linux desktop |
| `flutter analyze` | Run static analysis |
| `treefmt` | Format all files (Nix, Dart, YAML) |
| `nix fmt` | Format files using flake formatter |

## Formatting

This project uses `treefmt` to format code:

- **Alejandra** - Nix files
- **dart format** - Dart files
- **yamlfmt** - YAML files

Run `treefmt` to format all files, or `nix fmt` to use the flake formatter.

## Resources

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)
- [Flutter documentation](https://docs.flutter.dev/)
- [NixOS Wiki – Flutter](https://wiki.nixos.org/wiki/Flutter)
