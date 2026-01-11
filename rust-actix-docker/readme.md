# Rust, Actix & Diesel Nix Template

This is a starter pack for Nix friendly Rust Actix server with database on Rust ecosystem provided to you by [Bleur Stack]
members.

> Please, after bootstrapping, rename / change all `example` or `template` keywords in template files.

## Development

The project has `shell.nix` which has development environment preconfigured already for you. Just open your
terminal and at the root of this project:

```bash
# Open in bash by default
nix develop

# If you want other shell
nix develop -c $SHELL

# Upon entering development environment for the first
# time, development environment will bootstrap everything
# for you. You may use the environment as-is or modify
# it to your liking. Also don't forget to generate your own
# config.toml for development purposes.

cargo run config generate ./config.toml

# Please, don't forget to read contents of justfile,
# it will certainly make your DX way better.

just start # replace start with available command

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
./result/bin/server
```

## Deploying (works only for flake based NixOS)

Deploying this project, actix server requires host machine to have its own flake based configuration.

### Activation

In your configuration, add your project repository to `inputs`.

```nix
{
  inputs = {
    # ...

    # Let's imagine name of this project as `tempserver`
    tempserver.url = "github:somewhere/tempserver";
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
    inputs.tempserver.nixosModules.server
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
  # WARNING! `tempserver` shown below changes
  # depending on package name in your Cargo.toml
  # Basically it's generated like that:
  # => "{package.name}"
  # Replace package.name in your Cargo.toml with
  # {package.name}
  services.tempserver = {
    # Enable systemd service
    enable = true;

    # Port to host http server
    port = 25888;

    # Configurations for database
    database = {
      # Path to a file consisting only password for your database
      # Sops and secret manager friendly like:
      # config.sops.secrets."myserver/demo-server".path
      passwordFile = "/srv/tempserver-dbpass";
    };
  };
}
```

This is very basic and minimal example, you can tune other things like user who's going to run this systemd service, change group of user and many more. You can add your own modifications and add more options by yourself.

### Available default options

These are options that are available by default, just put services."${manifest.name}" before the keys:

#### `enable` (required) -> bool

Turn on systemd service of your server project.

#### `address` (optional) -> string

Address where server should listen to while hosting it via service, something like `127.0.0.1` or `0.0.0.0`.

#### `port` (optional) -> integer

Which port should be used to host your server.

#### `threads` (optional) -> integer

How many threads should be initialized for parallel request processing.

#### `proxy-reverse.enable` (optional) -> bool

Enable automatic web proxy configuration for either caddy or nginx. If the value is false, server will be deployed at `localhost` only. This is for people who don't have or want complex web server configurations.

#### `proxy-reverse.domain` (optional) -> string

It will be passed to web proxy to let it know whether to which domain the configurations should be appointed to.

#### `proxy-reverse.proxy` (optional) -> `caddy` or `nginx` as value

Choose which web server software should be integrated with.

#### `database.host` (optional) -> string

Address of host that is hosting database for this server. Local database will be created if not specified using socket connection.

#### `database.socketAuth` (optional) -> string

Whether to use authentication via socket for passworless local connection.

#### `database.socket` (optional) -> string

If socketAuth is true, then location to socket in your system should be specified to which this value is designed for.

#### `database.port` (optional) -> string

If you're using remote database, then specify port where your database is hosted at.

#### `database.name` (optional) -> string

Name of your database.

#### `database.user` (optional) -> string

Owner of database.

#### `database.passwordFile` (requried) -> string

Database password to pass to server, it should be a file that can be placed almost anywhere. Inside the file, there should be only database password as whole content. Don't type password directly as value for this option, it was done like that to don't expose your password openly in your public repository or expose it at /nix/store. Also, you can chain it with secret manager like `sops-nix` like that:

```nix
{
  sops.secrets = {
    "dbPass" = {
      owner = config.services.tempserver.user;
    };
  };

  services.tempserver.database.passwordFile = config.sops.secrets."dbPass".path;
}
```

#### `user` (optional) -> string

The user that will run the your server. It's defaulted to "{package.name}".

#### `group` (optional) -> string

Name of a group to which the user that's going to run your server should be added to. It's defaulted to the name of the user.

#### `dataDir` (optional) -> path

A location where working directory should be set to before starting your server. If you have a code to write something in current working directory, the value to this option is where it will be written. It's defaulted to "/var/lib/{package.name}".

#### `package` (optional) -> nix package

The packaged server with pre-compiled binaries and whatever. Defaulted to current project's build output and highly suggested to not change value of this option unless you know what you're doing.

## Working productions

There are bunch of servers that are using this template and are deployed to which you may refer as working examples:

- [Floss Registry](https://reg.floss.uz) - [GitHub](https://github.com/floss-uz/registrar) / To be deployed

## Docker (only for development, not for production)

This project includes a `docker-compose.yml` for local development with PostgreSQL. The setup is designed to be manually started and automatically stopped when your system shuts down.

### Prerequisites

### Usage

Start the PostgreSQL database:

```bash
# Start database in background
docker-compose up -d

# Or use podman-compose
podman-compose up -d
```

Stop the database:

```bash
docker-compose down

# Or with podman-compose
podman-compose down
```

View logs:

```bash
docker-compose logs -f postgres
```

Access PostgreSQL CLI:

```bash
docker-compose exec postgres psql -U temp -d temp
```

Clean up everything (including data):

```bash
docker-compose down -v
rm -rf docker-data/
```

### Configuration

The default credentials are:

- **Username**: `temp`
- **Password**: `temp`
- **Database**: `temp`
- **Port**: `5432`

These can be changed in the `docker-compose.yml` file or via environment variables in a `.env` file:

```bash
POSTGRES_USER=myuser
POSTGRES_PASSWORD=mypass
POSTGRES_DB=mydb
```

### Connection String

When running your Actix server, use this connection string in your `.env` or `config.toml`:

```
DATABASE_URL=postgres://temp:temp@localhost:5432/temp
```

### Why Not Production?

This Docker setup is configured for **development only** because:

- Uses permissive security settings (trust authentication, open remote access)
- Stores data in project directory (not persistent across clean builds)
- No backup or replication configured
- No resource limits or monitoring
- Runs as root inside container

For production deployments, we use systemd services with proper PostgreSQL configuration. Refer to the [Deploying section](#deploying-works-only-for-flake-based-nixos) for NixOS-based production deployment.

### Troubleshooting

**Port already in use?**

Change the port in `docker-compose.yml`:

```yaml
ports:
  - "5433:5432" # Use 5433 instead of 5432
```

## FAQ

### Why not use default.nix for devShell?

There's been cases when I wanted to reproduce totally different behaviors in development environment and
production build. This occurs quite a lot lately for some reason and because of that, I tend to keep
both shell.nix and default.nix to don't mix things up.

[Bleur Stack]: https://github.com/bleur-org
[available default options]: #available-default-options
