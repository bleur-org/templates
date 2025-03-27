flake: {
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services."${manifest.name}-bot";
  bot = flake.packages.${pkgs.stdenv.hostPlatform.system}.default;

  # Manifest via Cargo.toml
  manifest = (pkgs.lib.importTOML ./Cargo.toml).package;

  genArgs = {cfg}: let
    token = cfg.token;
    domain = cfg.webhook.domain or "";
    mode =
      if cfg.webhook.enable
      then "webhook"
      else "polling";
    port =
      if cfg.webhook.enable
      then "--port ${toString cfg.webhook.port}"
      else "";
  in
    lib.strings.concatStringsSep " " [mode token domain port];

  caddy = lib.mkIf (cfg.enable && cfg.webhook.enable && cfg.webhook.proxy == "caddy") {
    services.caddy.virtualHosts = lib.debug.traceIf (builtins.isNull cfg.webhook.domain) "webhook.domain can't be null, please specicy it properly!" {
      "${cfg.webhook.domain}" = {
        extraConfig = ''
          reverse_proxy 127.0.0.1:${toString cfg.webhook.port}
        '';
      };
    };
  };

  nginx = lib.mkIf (cfg.enable && cfg.webhook.enable && cfg.webhook.proxy == "nginx") {
    services.nginx.virtualHosts = lib.debug.traceIf (builtins.isNull cfg.webhook.domain) "webhook.domain can't be null, please specicy it properly!" {
      "${cfg.webhook.domain}" = {
        addSSL = true;
        enableACME = true;
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.webhook.port}";
          proxyWebsockets = true;
        };
      };
    };
  };

  service = lib.mkIf cfg.enable {
    users.users.${cfg.user} = {
      description = "${manifest.name} Telegram Bot user";
      isSystemUser = true;
      group = cfg.group;
    };

    users.groups.${cfg.group} = {};

    systemd.services."${manifest.name}-bot" = {
      description = "${manifest.name} Telegram Bot made from a template by Xinux";
      documentation = ["https://github.com/xinux-org/templates/tree/main/rust-telegram"];

      after = ["network-online.target"];
      wants = ["network-online.target"];
      wantedBy = ["multi-user.target"];

      serviceConfig = {
        User = cfg.user;
        Group = cfg.group;
        Restart = "always";
        ExecStart = "${lib.getBin cfg.package}/bin/${manifest.name} ${genArgs {cfg = cfg;}}";
        StateDirectory = cfg.user;
        StateDirectoryMode = "0750";
        # EnvironmentFile = cfg.secret;

        # Hardening
        CapabilityBoundingSet = [
          "AF_NETLINK"
          "AF_INET"
          "AF_INET6"
        ];
        DeviceAllow = ["/dev/stdin r"];
        DevicePolicy = "strict";
        IPAddressAllow = "localhost";
        LockPersonality = true;
        # MemoryDenyWriteExecute = true;
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

  asserts = lib.mkIf cfg.enable {
    warnings = [
      (lib.mkIf (cfg.webhook.enable && cfg.webhook.domain == null) "services.${manifest.name}.bot.webhook.domain must be set in order to properly generate certificate!")
    ];

    assertions = [
      {
        assertion = cfg.token != null;
        message = "services.${manifest.name}.bot.token must be set!";
      }
    ];
  };
in {
  options = with lib; {
    services."${manifest.name}-bot" = {
      enable = mkEnableOption ''
        ${manifest.name} Telegram bot template from Xinux community.
      '';

      webhook = {
        enable = mkEnableOption ''
          Webhook method of deployment
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

        port = mkOption {
          type = types.int;
          default = 39393;
          description = "Port to use for passing over proxy";
        };
      };

      token = mkOption {
        type = with types; nullOr path;
        default = null;
        description = lib.mdDoc ''
          Path to telegram bot token of ${manifest.name}.
        '';
      };

      user = mkOption {
        type = types.str;
        default = "${manifest.name}-bot";
        description = "User for running system + accessing keys";
      };

      group = mkOption {
        type = types.str;
        default = "${manifest.name}-bot";
        description = "Group for running system + accessing keys";
      };

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/${manifest.name}";
        description = lib.mdDoc ''
          The path where ${manifest.name} Telegram Bot keeps its config, data, and logs.
        '';
      };

      package = mkOption {
        type = types.package;
        default = bot;
        description = ''
          The ${manifest.name} Telegram Bot package to use with the service.
        '';
      };
    };
  };

  config = lib.mkMerge [asserts service caddy nginx];
}
