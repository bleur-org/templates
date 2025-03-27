# Telegram Rust Nix Template

This is a starter pack for Nix friendly Telegram bot project on Rust ecosystem provided to you by [Xinux Community]
members. The project uses fenix to fetch Rust toolchain from rustup catalogue and unfortunately, it fetches and patches
once (untill you clean cache) the whole rustup toolchain and THEN build the program or run.

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

# Upon entering development environment for the first
# time, you'll be asked for your development telegram
# bot token, it will be written to .env file for more
# convenient dev env startups. Token is saved at .env
# file at the root of this project. You can change it
# whenever you want!

# After entering development environment, inside the
# env, you can open your editor, so your editor will
# read all $PATH and environmental variables, also
# your terminal inside your editor will adopt all
# variables, so, you can close terminal.

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

Well, there are two ways of building your project. You can either go with classic `cargo build` way, but before that, make sure to enter development environment to have cargo and all rust toolchain available in your PATH, you may do like that:

```bash
# Entering development environment
nix develop -c $SHELL

# Compile the project
cargo build --release
```

Or, you can build your project via nix which will do all the dirty work for you. Just, in your terminal:

```bash
# Build in nix environment
nix build

# Executable binary is available at:
./result/bin/tempbot
```

## Deploying (works only for flake based NixOS)

Deploying this project, telegram bot requires host machine to have its own flake based configuration.

### Activation

In your configuration, add your project repository to `inputs`.

```nix
{
  inputs = {
    # ...

    # Let's imagine name of this project as `tempbot`
    tempbot.url = "github:somewhere/tempbot";
  };
}
```

Ok, now we have your project in repository list and now, we need to make use of options provided by modules of your project. In order to do that, we need to activate our module by importing our module. In your configuration.nix, find where you imported things and then add your project like that:

```nix
# Most of the time it's at the top part of nix configurations
# and written only once in a nix file.
{ ... }: {
  # ... something

  # And here begins like that
  imports = [
    # Imagine here your existing imports

    # Now import your project module like this
    inputs.tempbot.nixosModules.bot
  ];
};
```

Alright! Since we imported the module of our project and options are now available, now head into setting up section!

### Set up

Options are available, modules are activated and everything is ready to deploy, but now, we need to explain NixOS how
to deploy our project by writing some Nix configs. I already wrote some options and configurations which will be available
by default after project bootstrap, you are free to modify, add and remove whatever inside `module.nix` to your
liking. If you need list of available default options or explanations for every option, refer to [available default options] section below. In this guide, I'll
be showing you an example set up you may use to get started very fast, you'll find out the rest option by yourself if you
need something else. In your `configuration.nix` or wherever of your configuration:

```nix
{
  # WARNING! `tempbot-bot` shown below changes
  # depending on package name in your Cargo.toml
  # Basically it's generated like that:
  # => "{package.name}-bot"
  # Replace package.name in your Cargo.toml with
  # {package.name}
  services.tempbot-bot = {
    # Enable systemd service
    enable = true;

    # Telegram bot token passed to your bot via arguments
    token = "/srv/bot-token";

    # Enabling webhook integration which activates
    # caddy or nixos part of nix configuration at
    # `module.nix`
    webhook = {
      # Activate webhook part of nix configuration
      enable = true;

      # From given options (caddy or nginx), choose
      # web server to deploy bot via an http server
      proxy = "caddy";

      # Domain to pass to web server (caddy or nginx)
      domain = "mybot.mysite.uz";

      # Port to host http server and tell web proxy
      # to were bind that proxy
      port = 8445;
    };
  };
}
```

This is very basic examples, you can tune other things like user who's going to run this systemd service, change group of user and many more. You can add your own modifications and add more options by yourself.

### Available default options

These are options that are available by default, just put services."${manifest.name}-bot" before the keys:

#### `enable` (required) -> bool

Turn on systemd service of telegram bot project.

#### `token` (required) -> path to file

Telegram bot token to pass to telegram bot, it should be a file that can be placed almost anywhere. Inside the file, there should be only telegram bot token as whole content. Don't type telegram bot token directly as value for this option, it was done like that to don't expose your token openly in your public repository or expose it at /nix/store. Also, you can chain it with secret manager like `sops-nix` like that:

```nix
{
  sops.secrets = {
    "mytoken" = {
      owner = config.services.tempbot-bot.user;
    };
  };

  services.tempbot-bot.token = config.sops.secrets."mytoken".path;
}
```

#### `webhook.enable` (optional) -> bool

Enable automatic web proxy configuration for either caddy or nginx. If the value is false, telegram bot will be deployed in `polling` mode. This is for people who have or want complex web server configurations.

#### `webhook.proxy` (optional) -> `caddy` or `nginx` as value

Choose which web server software should be integrated with.

#### `webhook.domain` (optional) -> string

It will be passed to web proxy to let it know whether to which domain the configurations should be appointed to.

#### `webhook.port` (optional) -> integer

Which port should be used to host bot and proxy.

#### `user` (optional) -> string

The user that will run the telegram bot. It's defaulted to "{package.name}-bot".

#### `group` (optional) -> string

Name of a group to which the user that's going to run the telegram bot should be added to. It's defaulted to the name of the user.

#### `dataDir` (optional) -> path

A location where working directory should be set to before starting telegram bot. If you have a code to write something in current working directory, the value to this option is where it will be written. It's defaulted to "/var/lib/{package.name}-bot".

#### `package` (optional) -> nix package

The packaged telegram bot with pre-compiled binaries and whatever. Defaulted to current project's build output and highly suggested to not change value of this option unless you know what you're doing.

## Working productions

There are bunch of telegram bots that are using this template and are deployed to which you may refer as working examples:

- [Xinux Assistant](https://t.me/xinuxmgrbot) - [GitHub](https://github.com/xinux-org/telegram) / [Deployed At](https://github.com/kolyma-labs/instances/blob/main/nixos/kolyma-2/services/xinux.nix)
- [Rust Uzbekistan Assistant](https://t.me/rustaceanbot) - [GitHub](https://github.com/rust-lang-uz/telegram) / [Deployed At](https://github.com/kolyma-labs/instances/blob/main/nixos/kolyma-2/services/rustina.nix)

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

[Xinux Community]: https://github.com/xinux-org
[available default options]: #available-default-options
