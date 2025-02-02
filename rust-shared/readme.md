# Rust Static C Library Template

This is a starter pack for those who are writing C static library on Rust ecosystem which is provided to you by Xinux Community members.

> Please, after bootstrapping, rename / change all `example` or `template` keywords in template files.

## Development

I wrote `justfile` for you from which you can approximately understand how I'm running my library. Also...

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

# Check out library outputs
ls -la ./result/lib/
ls -la ./result/include/
```
