{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
    inputs.git-hooks.flakeModule
  ];

  perSystem =
    {
      config,
      # self',
      # inputs',
      pkgs,
      # system,
      ...
    }:
    {
      treefmt = {
        projectRootFile = "flake.nix";
        programs = {
          nixfmt.enable = true;
          prettier.enable = true;
          statix.enable = true;
          deadnix.enable = true;
          yamlfmt.enable = true;
          taplo.enable = true;

          ruff.enable = true;
        };
      };

      pre-commit = {
        check.enable = true;
        settings.hooks = {
          treefmt.enable = true;

          end-of-file-fixer.enable = true;
          trim-trailing-whitespace.enable = true;
          check-added-large-files.enable = true;

          # Specific uv lock check to ensure it's up to date
          # (Optional: run 'uv lock --check' here)
        };
      };

      devShells.default = pkgs.mkShell {
        shellHook = config.pre-commit.installationScript;

        nativeBuildInputs = with pkgs; [
          config.treefmt.build.wrapper
          just
          nixd

          basedpyright
          ruff

          # C dynamic libraries for uv to work properly
          stdenv.cc.cc
          zlib
        ];

        packages = with pkgs; [
          uv
          python313
        ];

        env = {
          UV_PYTHON_PREFERENCE = "only-managed";
        };

        LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (
          with pkgs;
          [
            stdenv.cc.cc.lib
            zlib
          ]
        );
      };
    };
}
