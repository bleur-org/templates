# C, GTK & Nix Template

This is a starter pack for Nix friendly GTK application with via C ecosystem provided to you
by [Bleur Stack] developers.

## Building the project

There are basically 2 ways of building this project.

### Nix

All you need is nix package manager and the rest is already done for you:

```bash
# Build in nix environment
nix build

# Executable binary is available at:
./result/bin/cgtk
```

## Running the project

The same goes for running the project.

### Nix

If you've ran the nix build command, you already have pre-compiled binary available to run at:

```bash
# Executable binary is available at:
./result/bin/cgtk
```

Also, you can directly run `nix run` without having to run build command first which will instantly open the application for you:

```bash
# Nix will automatically open executable
nix run
```

## FAQ

### Why not use default.nix for devShell?

There's been cases when I wanted to reproduce totally different behaviors in development environment and
production build. This occurs quite a lot lately for some reason and because of that, I tend to keep
both shell.nix and default.nix to don't mix things up.

[Bleur Stack]: https://github.com/bleur-org
