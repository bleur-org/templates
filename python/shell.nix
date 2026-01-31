{pkgs}: let
  manifest = (pkgs.lib.importTOML ./pyproject.toml).project;

  pythonEnv = pkgs.python314.withPackages (ps:
    with ps; [
      pip
      mypy
      pytest
      pytest-asyncio
      pytest-cov
      sphinx-book-theme
      sphinx-copybutton
    ]);
in
  pkgs.stdenv.mkDerivation {
    name = "${manifest.name}-dev";

    nativeBuildInputs = with pkgs; [
      nixd
      statix
      deadnix
      alejandra

      pythonEnv
      uv
      git
      ruff
      commitizen
      sphinx
    ];

    shellHook = ''
      source ./.env
    '';
  }
