# Nightly Rust Nix Template

This is a starter pack for Nix friendly Rust project ecosystem provided to you by Xinux Community members.

> Please, after bootstrapping, rename / change all `example` or `template` keywords in template files.

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
