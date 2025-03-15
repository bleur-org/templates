flake: {
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkOption mkIf mkMerge types;

  # Manifest via Cargo.toml
  manifest = (pkgs.lib.importTOML ./Cargo.toml).workspace.package;

  # Options
  cfg = config.services.${manifest.name};

  # Flake shipped default binary
  fpkg = flake.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # Toml management
  toml = pkgs.formats.toml {};

  # Find out whether shall we manage database locally
  local-database = cfg.database.host == "127.0.0.1";

  # The digesting configuration of server
  config = toml.generate "config.toml" {
    threads = 1;
    port = 8000;
    url = "127.0.0.1";
    database_url = "#databaseUrl#";
  };

  # Caddy proxy reversing
  caddy = mkIf (cfg.enable && cfg.proxy == "caddy") {
    services.caddy.virtualHosts = lib.debug.traceIf (builtins.isNull cfg.proxy-reverse.domain) "domain can't be null, please specicy it properly!" {
      "${cfg.proxy-reverse.domain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString cfg.port}
        '';
      };
    };
  };

  # Nginx proxy reversing
  nginx = mkIf (cfg.enable && cfg.proxy == "nginx") {
    services.nginx.virtualHosts = lib.debug.traceIf (builtins.isNull cfg.proxy-reverse.domain) "domain can't be null, please specicy it properly!" {
      "${cfg.proxy-reverse.domain}" = {
        addSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.port}";
          proxyWebsockets = true;
        };
      };
    };
  };

  # Systemd services
  service = mkIf cfg.enable {
    ## User for our services
    users.users = lib.mkIf (cfg.user == manifest.name) {
      ${manifest.name} = {
        description = "${manifest.name} Service";
        home = cfg.dataDir;
        useDefaultShell = true;
        group = cfg.group;
        isSystemUser = true;
      };
    };

    ## Group to join our user
    users.groups = mkIf (cfg.group == manifest.name) {
      ${manifest.name} = {};
    };

    ## Postgresql service (turn on if it's not already on)
    services.postgresql = lib.optionalAttrs (local-database && cfg.database.createDatabase) {
      enable = lib.mkDefault true;

      ensureDatabases = [cfg.database.name];
      ensureUsers = [
        {
          name = cfg.database.user;
          ensureDBOwnership = true;
          ensurePermissions = {
            "DATABASE ${cfg.database.name}" = "ALL PRIVILEGES";
          };
        }
      ];
    };

    # Configurator service (before actual server)
    systemd.services."${manifest.name}-config" = {
      wantedBy = ["${manifest.name}.target"];
      partOf = ["${manifest.name}.target"];
      path = with pkgs; [
        jq
        openssl
        replace-secret
      ];

      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        Group = cfg.group;
        TimeoutSec = "infinity";
        Restart = "on-failure";
        WorkingDirectory = "${cfg.dataDir}";
        RemainAfterExit = true;

        ExecStartPre = let
          preStartFullPrivileges = ''
            set -o errexit -o pipefail -o nounset
            shopt -s dotglob nullglob inherit_errexit

            chown --no-dereference '${cfg.user}':'${cfg.group}' '${cfg.dataDir}'/*
          '';
        in "+${pkgs.writeShellScript "${manifest.name}-pre-start-full-privileges" preStartFullPrivileges}";

        ExecStart = let
          inherit (lib) optionalString;
        in
          pkgs.writeShellScript "${manifest.name}-config" ''
            set -o errexit -o pipefail -o nounset
            shopt -s inherit_errexit

            umask u=rwx,g=rx,o=

            # Write configuration file for server
            cp -f ${config} ${cfg.dataDir}/config.toml

            # Write .env file for diesel migration
            echo DATABASE_URL=postgres://${cfg.database.user}:#databaseUrl#@${cfg.database.host}:${cfg.database.port}/${cfg.database.name} > ${cfg.dataDir}/.env

            # Replace #databaseUrl# with content from cfg.database.passwordFile
            ${optionalString (cfg.database.passwordFile != null) ''
              db_password="$(<'${cfg.database.passwordFile}')"
              export db_password

              if [[ -z "$db_password" ]]; then
                >&2 echo "Database password was an empty string!"
                exit 1
              fi

              replace-secret '#databaseUrl#' '${cfg.database.passwordFile}' '${cfg.dataDir}/.env'

              source ${cfg.dataDir}/.env
              sed -i "s|#databaseUrl#|$DATABASE_URL|g" "${cfg.dataDir}/config.toml"
            ''}

            # No password file, so remove #databaseUrl#
            ${optionalString (cfg.database.passwordFile == null) ''
              sed -i "s|#databaseUrl#||g" "${cfg.dataDir}/.env"
              sed -i "s|#databaseUrl#||g" "${cfg.dataDir}/config.toml"
            ''}
          '';
      };
    };

    # Configurator service (before actual server)
    systemd.services."${manifest.name}-migration" = {
      after = ["${manifest.name}-config.service"] ++ lib.optional local-database "postgresql.service";
      wantedBy = ["${manifest.name}.target"];
      partOf = ["${manifest.name}.target"];
      path = with pkgs; [
        diesel-cli
        diesel-cli-diesel-cli-ext
      ];

      serviceConfig = {
        Type = "oneshot";
        User = cfg.user;
        Group = cfg.group;
        TimeoutSec = "infinity";
        Restart = "on-failure";
        WorkingDirectory = "${cfg.dataDir}";
        RemainAfterExit = true;

        ExecStartPre = let
          preStartFullPrivileges = ''
            set -o errexit -o pipefail -o nounset
            shopt -s dotglob nullglob inherit_errexit

            chown --no-dereference '${cfg.user}':'${cfg.group}' '${cfg.dataDir}'/*
          '';
        in "+${pkgs.writeShellScript "${manifest.name}-pre-start-full-privileges" preStartFullPrivileges}";

        ExecStart = pkgs.writeShellScript "${manifest.name}-migration" ''
          set -o errexit -o pipefail -o nounset
          shopt -s inherit_errexit

          umask u=rwx,g=rx,o=

          # Paths
          migrations_dir="${cfg.package}/mgrs/migrations"
          migrations_file="${cfg.dataDir}/MIGRATIONS"

          # Get the list of available migrations (sorted for consistency)
          new_migrations=$(ls -1 "$migrations_dir" | sort | tr '\n' ' ')

          # Read the saved migrations list if the file exists, otherwise set to empty
          if [[ -f "$migrations_file" ]]; then
              saved_migrations=$(<"$migrations_file")
          else
              saved_migrations=""
          fi

          # If migrations are different, apply new migrations
          if [[ "$new_migrations" != "$saved_migrations" ]]; then
              echo "New migrations detected. Running migrations..."

              # Copy the migrations folder to ${cfg.dataDir}
              cp -r "$migrations_dir" "${cfg.dataDir}/migrations"

              # Copy .env into the migrations directory
              cp "${cfg.dataDir}/.env" "${cfg.dataDir}/migrations/"

              # Change to the migrations directory
              cd "${cfg.dataDir}/migrations"

              # Run Diesel migrations
              diesel migration run

              # Return to the original directory
              cd -

              # Remove the temporary migrations directory
              rm -rf "${cfg.dataDir}/migrations"

              # Save the new migrations list
              echo "$new_migrations" > "$migrations_file"
          else
              echo "Migrations are up to date. No action needed."
          fi
        '';
      };
    };

    ## Main server service
    systemd.services."${manifest.name}" = {
      description = "${manifest.name} Rust Actix server";
      documentation = [manifest.homepage];

      after = ["network.target" "${manifest.name}-config.service" "${manifest.name}-migration.service"] ++ lib.optional local-database "postgresql.service";
      requires = lib.optional local-database "postgresql.service";
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];
      path = [cfg.package];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Restart = "always";
        ExecStart = "${lib.getBin cfg.package}/bin/server server run ${cfg.dataDir}/config.toml";
        StateDirectory = cfg.user;
        StateDirectoryMode = "0750";
        # Access write directories
        ReadWritePaths = [cfg.dataDir];
        CapabilityBoundingSet = [
          "AF_NETLINK"
          "AF_INET"
          "AF_INET6"
        ];
        DeviceAllow = ["/dev/stdin r"];
        DevicePolicy = "strict";
        IPAddressAllow = "localhost";
        LockPersonality = true;
        NoNewPrivileges = true;
        PrivateDevices = true;
        PrivateTmp = true;
        PrivateUsers = true;
        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectHostname = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectSystem = "strict";
        ReadOnlyPaths = ["/"];
        RemoveIPC = true;
        RestrictAddressFamilies = [
          "AF_NETLINK"
          "AF_INET"
          "AF_INET6"
        ];
        RestrictNamespaces = true;
        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        SystemCallFilter = [
          "@system-service"
          "~@privileged"
          "~@resources"
          "@pkey"
        ];
        UMask = "0027";
      };
    };
  };

  # Various checks and tests of options
  asserts = lib.mkIf cfg.enable {
    ## Warning (nixos-rebuild doesn't fail if any warning shows up)
    warnings = [
      (lib.mkIf (cfg.proxy-reverse.enable && cfg.proxy-reverse.domain == null) "services.${manifest.name}.proxy-reverse.domain must be set in order to properly generate certificate!")
    ];

    ## Tests (nixos-rebuilds fails if any test fails)
    assertions = [
      {
        assertion = cfg.database.passwordFile != null;
        message = "services.${manifest.name}.database.passwordFile must be set!";
      }
    ];
  };
in {
  # Available user options
  options = with lib; {
    services.${manifest.name} = {
      enable = mkEnableOption ''
        ${manifest.name}, actix + diesel server on rust.
      '';

      proxy-reverse = {
        enable = mkEnableOption ''
          Enable proxy reversing via nginx/caddy.
        '';

        domain = mkOption {
          type = with types; nullOr str;
          default = null;
          example = "xinux.uz";
          description = "Domain to use while adding configurations to web proxy server";
        };

        proxy = mkOption {
          type = with types;
            nullOr (enum [
              "nginx"
              "caddy"
            ]);
          default = "caddy";
          description = "Proxy reverse software for hosting webhook";
        };
      };

      port = mkOption {
        type = types.int;
        default = 39393;
        description = "Port to use for passing over proxy";
      };

      database = {
        host = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = "Database host address. Leave \"127.0.0.1\" if you want local database";
        };

        port = mkOption {
          type = types.port;
          default = pg.settings.port;
          defaultText = "5432";
          description = "Database host port";
        };

        name = mkOption {
          type = types.str;
          default = manifest.name;
          description = "Database name";
        };

        user = mkOption {
          type = types.str;
          default = manifest.name;
          description = "Database user.";
        };

        passwordFile = mkOption {
          type = types.nullOr types.path;
          default = null;
          example = "/run/keys/${manifest-name}-dbpassword";
          description = ''
            A file containing the password corresponding to
            {option}`database.user`.
          '';
        };
      };

      user = mkOption {
        type = types.str;
        default = "${manifest.name}";
        description = "User for running system + accessing keys";
      };

      group = mkOption {
        type = types.str;
        default = "${manifest.name}";
        description = "Group for running system + accessing keys";
      };

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/${manifest.name}";
        description = lib.mdDoc ''
          The path where ${manifest.name} keeps its config, data, and logs.
        '';
      };

      package = mkOption {
        type = types.package;
        default = fpkg;
        description = ''
          Compiled ${manifest.name} actix server to use with the service.
        '';
      };
    };
  };

  config = mkMerge [asserts service caddy nginx];
}
