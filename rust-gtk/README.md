# Rust, Relm4, GTK & Nix Template

This is a starter pack for Nix friendly GTK application with Relm4 via Rust ecosystem provided to you
by [Bleur Stack] developers.

<div align="center">

![Main window](data/resources/screenshots/screenshot1.png "Main window")

</div>

## What does it contains?

- A simple window with a headerbar
- Bunch of useful files that you SHOULD ship with your application on Linux:
  - Metainfo: describe your application for the different application stores out there;
  - Desktop: the application launcher;
  - Icons: This repo contains three icons, a normal, a nightly & monochromatic icon (symbolic) per the GNOME HIG, exported using [App Icon Preview](https://flathub.org/apps/details/org.gnome.design.AppIconPreview).
- Flatpak Manifest for nightly builds
- Dual installation support
- Uses Meson for building the application
- Bundles the UI files & the CSS using gresources
- A pre-commit hook to run rustfmt on your code
- Tests to validate your Metainfo, Schemas & Desktop files
- Gsettings to store the window state, more settings could be added
- Gitlab CI to produce flatpak nightlies
- i18n support

## How to init a project ?

> Remove python bootstrap in favor of cli bleur tool.

The template ships a simple python script to init a project easily. It asks you a few questions and replaces & renames all the necessary files.

If you clone this repository, you can run it with:

```shell
➜ python create-project.py
Welcome to GTK Rust Template
Name: Contrast
Project Name: contrast
Application ID (e.g. org.domain.MyAwesomeApp, see: https://developer.gnome.org/ChooseApplicationID/): org.gnome.design.Contrast
Author: Bleur Developers
Email: support@bleur.net
```

A new directory named `contrast` containing the generated project

## Building the project

There are basically 2 ways of building this project.

### Nix

All you need is nix package manager and the rest is already done for you:

```bash
# Build in nix environment
nix build

# Executable binary is available at:
./result/bin/app-name
```

### Flatpak

Make sure you have `flatpak` and `flatpak-builder` installed. Then run the commands below. Replace `<application_id>` with the value you entered during project creation. Please note that these commands are just for demonstration purposes. Normally this would be handled by your IDE, such as GNOME Builder or VS Code with the Flatpak extension.

```shell
flatpak install --user org.gnome.Sdk//46 org.gnome.Platform//46  org.freedesktop.Sdk.Extension.rust-stable//23.08 org.freedesktop.Sdk.Extension.llvm16//23.08
flatpak-builder --user flatpak_app build-aux/<application_id>.Devel.json
```

## Running the project

The same goes for running the project.

### Nix

If you've ran the nix build command, you already have pre-compiled binary available to run at:

```bash
# Executable binary is available at:
./result/bin/app-name
```

Also, you can directly run `nix run` without having to run build command first which will instantly open the application for you:

```bash
# Nix will automatically open executable
nix run
```

### Flatpak

Once the project is build, run the command below. Replace `<application_id>` and `<project_name>` with the values you entered during project creation. Please note that these commands are just for demonstration purposes. Normally this would be handled by your IDE, such as GNOME Builder or VS Code with the Flatpak extension.

```shell
flatpak-builder --run flatpak_app build-aux/<application_id>.Devel.json <project_name>
```

## Translations with Gettext

The template uses `gettext` as a framework for translations using [`gettext-rs`](https://github.com/gettext-rs/gettext-rs). The basic files for this can be found in the `po` folder.
While meson will take care of building the translations the extraction and translation itself has to be done manually.

### Extracting translatable strings

First of all you have to have `gettext` installed on your system. With that you then are able to use `xgettext` as following to extract the translatable strings:

```shell
xgettext --package-name=<project_name> --package-version=main --msgid-bugs-address=https://github.com/<project_name>/<project_name>/issues --files-from=po/POTFILES.in --output=po/<project_name>.pot
```

Note that you might need to update the `po/POTFILES.in` file to reflect the files of your process. This describes where `xgettext` is going to search for strings to translate.

### Translating the translatable strings

To translate the strings you need to use po files. Tools like Poedit allow you to generate these from the `po/<project_name>.pot` file.
It also allows you to sync the `po/<project_name>.pot` when you rerun `xgettext`.

When adding a po file also make sure to add the language code to `po/LINGUAS`.

## FAQ

### Why not use default.nix for devShell?

There's been cases when I wanted to reproduce totally different behaviors in development environment and
production build. This occurs quite a lot lately for some reason and because of that, I tend to keep
both shell.nix and default.nix to don't mix things up.

[Bleur Stack]: https://github.com/bleur-org
