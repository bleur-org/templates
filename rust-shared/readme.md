# Rust Nix Template

This is a starter pack for Nix friendly Rust ecosystem project to write a C static or shared library provided
to you by [Bleur Stack] developers. The project uses fenix to fetch Rust toolchain from rustup catalogue and
unfortunately, it fetches and patches once (untill you clean cache) the whole rustup toolchain and THEN build
the program or run.

> Please, after bootstrapping, rename / change all `example` or `template` keywords in template files.

## Rust Toolchain

Rustup toolchain is utilized and managed by Nix package manager via `rust-toolchain.toml` file which can be found
at the root path of your project. Feel free to modify toolchain file to customize toolchain behaviour.

## Development

The project has `shell.nix` which has development environment preconfigured already for you. Just open your
terminal and at the root of this project:

```bash
# Open in bash by default
nix develop

# If you want other shell
nix develop -c $SHELL

# After entering Nix development environment,
# inside the env, you can open your editor, so
# your editor will read all $PATH and environmental
# variables, also your terminal inside your editor
# will adopt all variables, so, you can close terminal.

# Neovim
vim .

# VSCode
code .

# Zed Editor
zed .
```

The development environment has whatever you may need already, but feel free to add or remove whatever
inside `shell.nix`.

## Building

> As we are building shared/static library, outputs may differ depending on the type of operating system you're building the project on. As an example, on macOS, you'll get <something>.dylib whereas on Linux, you'll get <something>.so.

Well, there are two ways of building your project. You can either go with classic `cargo build` way, but before that, make sure to enter development environment to have cargo and all rust toolchain available in your PATH, you may do like that:

```bash
# Entering development environment
nix develop -c $SHELL

# Compile the project
cargo build --release

# Grab the header file in the project root
# and get a copy of your shared library at
ls -la ./target/release/
```

Or, you can build your project via nix which will do all the dirty work for you. Just, in your terminal:

```bash
# Build in nix environment
nix build

# Nix will produce static/shared library with headers
ls -la ./result/lib/
ls -la ./result/include/
```

> [!NOTE]
> Writing tests in rust is good, but as cargo can't check eligibility of your header file, make sure to write a C program that will build and run with your library to ensure correct behaviour manually. Don't believe as it will work ✨magically✨!

## FAQ

### Why not use default.nix for devShell?

There's been cases when I wanted to reproduce totally different behaviors in development environment and
production build. This occurs quite a lot lately for some reason and because of that, I tend to keep
both shell.nix and default.nix to don't mix things up.

### Error when building or entering development environment

If you see something like that in the end:

```
error: hash mismatch in fixed-output derivation '/nix/store/fsrachja0ig5gijrkbpal1b031lzalf0-channel-rust-stable.toml.drv':
  specified: sha256-vMlz0zHduoXtrlu0Kj1jEp71tYFXyymACW8L4jzrzNA=
     got:    sha256-Hn2uaQzRLidAWpfmRwSRdImifGUCAb9HeAqTYFXWeQk=
```

Just know that something in that version of rustup changed or sha is outdated, so, just copy whatever
shown in `got` and place that in both `default.nix` and `shell.nix` at:

```
  # Rust Toolchain via fenix
  toolchain = fenix.packages.${pkgs.system}.fromToolchainFile {
    file = ./rust-toolchain.toml;

    # Bla bla bla bla bla, bla bla bla.
    #                     REPLACE THIS LONG THING!
    sha256 = "sha256-Hn2uaQzRLidAWpfmRwSRdImifGUCAb9HeAqTYFXWeQk=";
  };
```

[Bleur Stack]: https://github.com/bleur-org
