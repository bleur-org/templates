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
      - [Rust language](https://rust-lang.org)
      - [Ruby in the NixOS manual](https://nixos.org/manual/nixpkgs/stable/#rust)
      - [Rust NixOS Wiki](https://nixos.wiki/wiki/Rust)
      - [Fenix for Nix](https://github.com/nix-community/fenix)
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
      - [Rust language](https://rust-lang.org)
      - [Ruby in the NixOS manual](https://nixos.org/manual/nixpkgs/stable/#rust)
      - [Rust NixOS Wiki](https://nixos.wiki/wiki/Rust)
      - [Fenix for Nix](https://github.com/nix-community/fenix)
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
      - [Rust language](https://rust-lang.org)
      - [Libc-rs](https://docs.rs/libc/latest/libc/)
      - [Ruby in the NixOS manual](https://nixos.org/manual/nixpkgs/stable/#rust)
      - [Rust NixOS Wiki](https://nixos.wiki/wiki/Rust)
      - [Fenix for Nix](https://github.com/nix-community/fenix)
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
      - [Rust language](https://rust-lang.org)
      - [Teloxide](https://github.com/teloxide/teloxide/)
      - [Ruby in the NixOS manual](https://nixos.org/manual/nixpkgs/stable/#rust)
      - [Rust NixOS Wiki](https://nixos.wiki/wiki/Rust)
      - [Fenix for Nix](https://github.com/nix-community/fenix)
    '';
  };
}
