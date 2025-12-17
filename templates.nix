{
  # Stable Rust binary template
  rust = {
    path = ./rust;
    description = "Typical Rust project template using fenix";
    welcomeText = ''
      # Bleur stack simple Rust & Nix template

      ## Intended usage
      The intended usage of this flake is to write a project on Rust which compiles to an executable project

      ## Important
      Please, after bootstrapping your own project, don't forget to read readme.md for more infomration on usage.

      ## More info
      - [Rust language](https://rust-lang.org)
      - [Rust NixOS Wiki](https://nixos.wiki/wiki/Rust)
    '';
  };

  # Nightly Rust binary template
  rust-nightly = {
    path = ./rust-nightly;
    description = "Nightly Rust project template using fenix";
    welcomeText = ''
      # Bleur stack nightly Rust & Nix template

      ## Intended usage
      The intended usage of this flake is to write a project on nightly version of Rust toolchain which compiles to an executable project

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
      # Bleur stack C shared/static library with libc on Rust & Nix template

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
      # Bleur stack telegram bot on Rust & Nix with NixOS modules template
      ## Intended usage
      The intended usage of this flake is to write a Telegram bot on Rust and deploy it on NixOS server

      ## Important
      Please, after bootstrapping your own project, don't forget to read readme.md for more infomration on usage.

      ## More info
      - [Teloxide](https://github.com/teloxide/teloxide/)
      - [Rust language](https://rust-lang.org)
      - [Rust NixOS Wiki](https://nixos.wiki/wiki/Rust)
    '';
  };

  # Actix & Postgresql server on Rust template
  rust-actix = {
    path = ./rust-actix;
    description = "Actix & Postgresql server on Rust template";
    welcomeText = ''
      # Bleur stack actix & postgresql server on Rust & Nix template with NixOS modules
      ## Intended usage
      The intended usage of this flake is to write a backend server application on Rust/Actix and deploy it on NixOS server

      ## Important
      Please, after bootstrapping your own project, don't forget to read readme.md for more infomration on usage.

      ## More info
      - [Actix.rs](https://actix.rs)
      - [Diesel.rs](https://diesel.rs)
      - [Rust language](https://rust-lang.org)
      - [Rust NixOS Wiki](https://nixos.wiki/wiki/Rust)
    '';
  };

  # Relm4 stack based GTK rust app template with Crane
  rust-relm4 = {
    path = ./rust-relm4;
    description = "Minima Rust Relm4 GTK application";
    welcomeText = ''
      # Bleur stack Gnome GTK based Relm4 stack application on Rust & Nix template
      ## Intended usage
      The intended usage of this flake is to write a gui application via Relm4 stack leveraging Gnome's GTK on Rust and distribute via nixpkgs

      ## Important
      Please, after bootstrapping your own project, don't forget to read readme.md for more infomration on usage.

      ## More info
      - [GTK](https://www.gtk.org/)
      - [Relm4](https://relm4.org/)
      - [Rust language](https://rust-lang.org)
      - [Rust NixOS Wiki](https://nixos.wiki/wiki/Rust)
      - [Crane](https://crane.dev/getting-started.html)
    '';
  };

  # Minimal Relm4 stack based GTK rust app template
  rust-relm4-minimal = {
    path = ./rust-relm4-minimal;
    description = "Minima Rust Relm4 GTK application";
    welcomeText = ''
      # Bleur stack Gnome GTK based Relm4 stack application on Rust & Nix template
      ## Intended usage
      The intended usage of this flake is to write a gui application via Relm4 stack leveraging Gnome's GTK on Rust and distribute via nixpkgs

      ## Important
      Please, after bootstrapping your own project, don't forget to read readme.md for more infomration on usage.

      ## More info
      - [GTK](https://www.gtk.org/)
      - [Relm4](https://relm4.org/)
      - [Rust language](https://rust-lang.org)
      - [Rust NixOS Wiki](https://nixos.wiki/wiki/Rust)
    '';
  };

  # Rust, MdBook & Nix Template
  rust-book = {
    path = ./rust-book;
    description = "Rust, MdBook & Nix Template";
    welcomeText = ''
      # Bleur stack Rust, MdBook & Nix Template
      ## Intended usage
      The intended usage of this flake is to write book like documentation which can be used in many ways.

      ## Important
      Please, after bootstrapping your own project, don't forget to read readme.md for more infomration on usage.

      ## More info
      - [mdBook Documentation](https://rust-lang.github.io/mdBook/)
      - [Example](https://github.com/uzbek-net/programming-from-the-ground-up)
    '';
  };

  # Actix & Postgresql server on Rust template
  rust-actix-smol = {
    path = ./rust-actix-smol;
    description = "Actix & Postgresql server on Rust with Tokio swapped to Smol async runtime template";
    welcomeText = ''
      # Bleur stack actix via smol & postgresql server on Rust & Nix template with NixOS modules
      ## Intended usage
      The intended usage of this flake is to write a backend server application on Rust/Actix with Smol async runtime and deploy it on NixOS server

      ## Important
      Please, after bootstrapping your own project, don't forget to read readme.md for more infomration on usage.

      ## More info
      - [Actix.rs](https://actix.rs)
      - [Smol.rs](https://github.com/smol-rs/smol)
      - [Diesel.rs](https://diesel.rs)
      - [Rust language](https://rust-lang.org)
      - [Rust NixOS Wiki](https://nixos.wiki/wiki/Rust)
    '';
  };
}
