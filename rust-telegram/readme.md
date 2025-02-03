# Telegram Rust Nix Template

This is a starter pack for Nix friendly Telegram bot on Rust ecosystem provided to you by Xinux Community members.

> Please, after bootstrapping, rename / change all `example` or `template` keywords in template files.

## Table of contents

- [Development](#development)
- [Building](#building)
- [Deploying](#deploying)
- [Working productions](#working-productions)

## Development

In your project root:

```shell
# Default shell (bash)
nix develop

# If you use zsh
nix develop -c $SHELL

# If it's your first time, terminal will ask you for
# Telegram bot token to set up everything necessary
# and forget about it.

# Nix shell will run bot in background on watch mode.
# However, your terminal prompt may not show, so just
# Press enter and prompt will be back.

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
./result/bin/tempbot
```

## Deploying

WIP: This one is huge, will take some time to write.

## Working productions

There are bunch of telegram bots that are using this template and are deployed & working:

- [Xinux Assistant](https://t.me/xinuxmgrbot) - [GitHub](https://github.com/xinux-org/telegram) / [Deployed at](https://github.com/kolyma-labs/instances/blob/main/nixos/kolyma-2/services/xinux.nix)
- [Rust Uzbekistan Assistant](https://t.me/rustaceanbot) - [GitHub](https://github.com/rust-lang-uz/telegram) / [Deployed at](https://github.com/kolyma-labs/instances/blob/main/nixos/kolyma-2/services/rustina.nix)
