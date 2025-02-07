{
  # Stable Rust binary template
  rust = {
    path = ./rust;
    description = "Typical Rust project template using fenix";
    welcomeText = ''
      # Simple Rust Nix template by Xinux community
      ## Intended usage
      The intended usage of this flake is to write a project on Rust which compiles to an executable project

      ## Important
      Please, after bootstrapping your own project, don't forget to read readme.md for more infomration on usage.

      ## More info
      - [Fenix for Nix](https://github.com/nix-community/fenix)
      - [Rust language](https://rust-lang.org)
      - [Rust NixOS Wiki](https://nixos.wiki/wiki/Rust)
    '';
  };

  # Nightly Rust binary template
  rust-nightly = {
    path = ./rust-nightly;
    description = "Nightly Rust project template using fenix";
    welcomeText = ''
      # Nightly Rust Nix template by Xinux community
      ## Intended usage
      The intended usage of this flake is to write a project on nightly version of Rust which compiles to an executable project

      ## Important
      Please, after bootstrapping your own project, don't forget to read readme.md for more infomration on usage.

      ## More info
      - [Fenix for Nix](https://github.com/nix-community/fenix)
      - [Rust language](https://rust-lang.org)
      - [Rust NixOS Wiki](https://nixos.wiki/wiki/Rust)
    '';
  };

  # Static C library on Rust template
  rust-shared = {
    path = ./rust-shared;
    description = "C shared/static library with libc on Rust template";
    welcomeText = ''
      # C shared/static library with libc on Rust template by Xinux community
      ## Intended usage
      The intended usage of this flake is to write a C static/shared library with libc on Rust

      ## Important
      Please, after bootstrapping your own project, don't forget to read readme.md for more infomration on usage.

      ## More info
      - [Libc-rs](https://docs.rs/libc/latest/libc/)
      - [Fenix for Nix](https://github.com/nix-community/fenix)
      - [Rust language](https://rust-lang.org)
      - [Rust NixOS Wiki](https://nixos.wiki/wiki/Rust)
    '';
  };

  # Static C library on Rust template
  rust-telegram = {
    path = ./rust-telegram;
    description = "Telegram bot on Rust with NixOS modules template";
    welcomeText = ''
      # Telegram bot on Rust with NixOS modules template by Xinux community
      ## Intended usage
      The intended usage of this flake is to write a Telegram bot on Rust and deploy it on NixOS server

      ## Important
      Please, after bootstrapping your own project, don't forget to read readme.md for more infomration on usage.

      ## More info
      - [Teloxide](https://github.com/teloxide/teloxide/)
      - [Fenix for Nix](https://github.com/nix-community/fenix)
      - [Rust language](https://rust-lang.org)
      - [Rust NixOS Wiki](https://nixos.wiki/wiki/Rust)
    '';
  };

  # Actix & Postgresql server on Rust template
  rust-actix = {
    path = ./rust-actix;
    description = "Actix & Postgresql server on Rust template";
    welcomeText = ''
      # Actix & Postgresql server on Rust template with NixOS modules by Xinux community
      ## Intended usage
      The intended usage of this flake is to write a backend server application on Rust/Actix and deploy it on NixOS server

      ## Important
      Please, after bootstrapping your own project, don't forget to read readme.md for more infomration on usage.

      ## More info
      - [Actix.rs](https://actix.rs)
      - [Diesel.rs](https://diesel.rs)
      - [Fenix for Nix](https://github.com/nix-community/fenix)
      - [Rust language](https://rust-lang.org)
      - [Rust NixOS Wiki](https://nixos.wiki/wiki/Rust)
    '';
  };
}
