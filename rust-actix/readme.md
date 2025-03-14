# Rust Actix Template

This is a starter pack for Nix friendly Rust Actix project ecosystem provided to you by Xinux Community members.

> Please, after bootstrapping, rename / change all `example` or `template` keywords in template files.

## Getting started

Let's get introduced with the anatomy of the project and whether how does it work. After bootstrapping project, you
might have mentioned that we have `crates` directory where all rust codebases are being kept. Basically, we have 4 essential crates:

- cli - I didn't want to ship raw actix_main, so I created cli to make use and configuration of server binary much easier
  without having need to recompile the binary or being way too depended on ENVIRONMENTAL VARIABLES.
- database - this is where you can write all your database transactions, models and schemas for diesel, nothing more or less.
- http - actix crate serving as a partial controller and view like in MVC, but still being called from `cli` crate.
- utils - all necessary tools & utilities that would have been inside all 3 crates above, but kept independently to avoid spamming
  codebase.

## Development

In your project root:

```shell
# Default shell (bash)
nix develop

# If you use zsh
nix develop -c $SHELL

# After entering Nix development environment,
# inside the env, you can open your editor, so
# your editor will read all $PATH and environmental
# variables

# Neovim
vim .

# VSCode
code .

# Zed Editor
zed .
```

## Building

In your project root:

```shell
# Build in nix environment
nix build

# Execute compiled binary
./result/bin/template
```

## Migration

If you add new migrations, please, at least dump minor version higher to let deployed nix module know whether should it run migrations. It detects changes based on server binary cli's version.
