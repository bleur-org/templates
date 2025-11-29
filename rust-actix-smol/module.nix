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
  local-database = (
    (cfg.database.host == "127.0.0.1") || (cfg.database.host == "localhost")
  );

  # The digesting configuration of server
  toml-config = toml.generate "config.toml" {
    port = cfg.port;
    url = cfg.address;
    threads = cfg.threads;
    database_url = "#databaseUrl#";
  };

  # Caddy proxy reversing
  caddy = mkIf (cfg.enable && cfg.proxy-reverse.enable && cfg.proxy == "caddy") {
    services.caddy.virtualHosts = lib.debug.traceIf (builtins.isNull cfg.proxy-reverse.domain) "domain can't be null, please specicy it properly!" {
      "${cfg.proxy-reverse.domain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString cfg.port}
        '';
      };
    };
  };

  # Nginx proxy reversing
  nginx = mkIf (cfg.enable && cfg.proxy-reverse.enable && cfg.proxy == "nginx") {
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
    services.postgresql = lib.optionalAttrs local-database {
      enable = lib.mkDefault true;

      ensureDatabases = [cfg.database.name];
      ensureUsers = [
        {
          name = cfg.database.user;
          ensureDBOwnership = true;
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

            chown -R --no-dereference '${cfg.user}':'${cfg.group}' '${cfg.dataDir}'
            chmod -R u+rwX,g+rX,o-rwx '${cfg.dataDir}'
          '';
        in "+${pkgs.writeShellScript "${manifest.name}-pre-start-full-privileges" preStartFullPrivileges}";

        ExecStart = pkgs.writeShellScript "${manifest.name}-config" ''
          set -o errexit -o pipefail -o nounset
          shopt -s inherit_errexit

          umask u=rwx,g=rx,o=

          # Write configuration file for server
          cp -f ${toml-config} ${cfg.dataDir}/config.toml

          ${lib.optionalString cfg.database.socketAuth ''
            echo "DATABASE_URL=postgres://${cfg.database.user}@/${cfg.database.name}?host=${cfg.database.socket}" > "${cfg.dataDir}/.env"
            sed -i "s|#databaseUrl#|postgres://${cfg.database.user}@/${cfg.database.name}?host=${cfg.database.socket}|g" "${cfg.dataDir}/config.toml"
          ''}

          ${lib.optionalString (!cfg.database.socketAuth) ''
            echo "DATABASE_URL=postgres://${cfg.database.user}:#password#@${cfg.database.host}/${cfg.database.name}" > "${cfg.dataDir}/.env"
            replace-secret '#password#' '${cfg.database.passwordFile}' '${cfg.dataDir}/.env'
            source "${cfg.dataDir}/.env"
            sed -i "s|#databaseUrl#|$DATABASE_URL|g" "${cfg.dataDir}/config.toml"
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
        diesel-cli-ext
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

            chown -R --no-dereference '${cfg.user}':'${cfg.group}' '${cfg.dataDir}'
            chmod -R u+rwX,g+rX,o-rwx '${cfg.dataDir}'

            # In the future maybe, for faster perms
            # find '${cfg.dataDir}' \! -user '${cfg.user}' -exec chown '${cfg.user}':'${cfg.group}' {} +
            # find '${cfg.dataDir}' \! -perm /u+rw,g+r,o-rwx -exec chmod u+rwX,g+rX,o-rwx {} +

            rm -rf '${cfg.dataDir}/migrations'
          '';
        in "+${pkgs.writeShellScript "${manifest.name}-pre-start-full-privileges" preStartFullPrivileges}";

        ExecStart = pkgs.writeShellScript "${manifest.name}-migration" ''
          set -o errexit -o pipefail -o nounset
          shopt -s inherit_errexit

          umask u=rwx,g=rx,o=

          # Migration duplication
          migrations_rep="${cfg.package}/mgrs"
          target_dir="${cfg.dataDir}/migrations"

          # Migration checking
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

            # Copy entire mgrs as migrations
            cp -r "$migrations_rep" "$target_dir"

            # Explicitly set permissions
            chown -R '${cfg.user}':'${cfg.group}' "$target_dir"
            chmod -R u+rwX,g+rX,o-rwx "$target_dir"

            # Copy .env into the new migrations directory
            cp "${cfg.dataDir}/.env" "$target_dir/"

            # Run Diesel migrations from the migrations subdirectory
            cd "$target_dir/migrations"
            diesel migration run

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
        ExecReload = "${pkgs.coreutils}/bin/kill -s HUP $MAINPID";
        StateDirectory = cfg.user;
        StateDirectoryMode = "0750";
        # Access write directories
        ReadWritePaths = [cfg.dataDir "/run/postgresql"];
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
        PrivateUsers = false;
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
          "AF_UNIX"
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
    warnings = [];
    # ++ lib.optional
    # (cfg.proxy-reverse.enable && (cfg.proxy-reverse.domain == null || cfg.proxy-reverse.domain == ""))
    # "services.${manifest.name}.proxy-reverse.domain must be set in order to properly generate certificate!";

    ## Tests (nixos-rebuilds fails if any test fails)
    assertions =
      [
        {
          assertion = (!cfg.database.socketAuth) -> cfg.database.passwordFile != null;
          message = "services.${manifest.name}.database.passwordFile must be set when using remote database!";
        }
      ]
      ++ lib.optional
      (cfg.proxy-reverse.enable)
      {
        assertion = cfg.proxy-reverse.domain != null && cfg.proxy-reverse.domain != "";
        message = "You must specify a valid domain when proxy-reverse is enabled!";
      };
  };
in {
  # Available user options
  options = with lib; {
    services.${manifest.name} = {
      enable = mkEnableOption ''
        ${manifest.name}, actix + diesel server on rust.
      '';

      address = mkOption {
        type = types.str;
        default = "127.0.0.1";
        description = "Port to use for passing over proxy";
      };

      port = mkOption {
        type = types.int;
        default = 39393;
        description = "Port to use for passing over proxy";
      };

      threads = mkOption {
        type = types.int;
        default = 1;
        description = "How many cores to use while pooling";
      };

      proxy-reverse = {
        enable = mkEnableOption ''
          Enable proxy reversing via nginx/caddy.
        '';

        domain = mkOption {
          type = with types; nullOr str;
          default = null;
          example = "bleur.net";
          description = "Domain to use while adding configurations to web proxy server";
        };

        proxy = mkOption {
          type = with types;
            nullOr (enum [
              "nginx"
              "caddy"
            ]);
          default = "caddy";
          description = "Web server software for proxy reversing";
        };
      };

      database = {
        host = mkOption {
          type = types.str;
          default = "127.0.0.1";
          description = "Database host address. Leave \"127.0.0.1\" if you want local database";
        };

        socketAuth = mkOption {
          type = types.bool;
          default =
            if local-database
            then true
            else false;
          description = "Use Unix socket authentication for PostgreSQL instead of password authentication when local database wanted.";
        };

        socket = mkOption {
          type = types.nullOr types.path;
          default =
            if local-database
            then "/run/postgresql"
            else null;
          description = "Path to the PostgreSQL Unix socket.";
        };

        port = mkOption {
          type = types.port;
          default = config.services.postgresql.settings.port;
          defaultText = "5432";
          description = "Database host port.";
        };

        name = mkOption {
          type = types.str;
          default = manifest.name;
          description = "Database name.";
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
          Compiled ${manifest.name} actix server package to use with the service.
        '';
      };
    };
  };

  config = mkMerge [asserts service caddy nginx];
}
