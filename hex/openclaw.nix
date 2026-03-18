{
  config,
  pkgs,
  lib,
  nix-secrets,
  ...
}:
{
  # Permit the openclaw package which has known vulnerabilities for prompt injection
  # This is an explicit, per-host opt-in to the security risk
  nixpkgs.config.permittedInsecurePackages = [
    "openclaw-2026.2.26"
  ];

  # Restricted system user for openclaw service
  users.users.openclaw = {
    isSystemUser = true;
    group = "openclaw";
    home = "/var/lib/openclaw";
    createHome = true;
  };
  users.groups.openclaw = { };

  # Secrets management via sops-nix
  # Decrypt hex's secrets using its SSH host ed25519 key
  # The actual secrets file is in the nix-secrets repository
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  # Individual secrets for Slack tokens
  # Secrets are stored in nix-secrets repository
  sops.secrets."hex/openclaw/slack_app_token" = {
    sopsFile = "${nix-secrets}/secrets.yaml";
    owner = config.users.users.openclaw.name;
    group = config.users.users.openclaw.group;
    mode = "0400";
  };

  sops.secrets."hex/openclaw/slack_bot_token" = {
    sopsFile = "${nix-secrets}/secrets.yaml";
    owner = config.users.users.openclaw.name;
    group = config.users.users.openclaw.group;
    mode = "0400";
  };

  # Template to render environment file from secrets
  # This allows the service to reference secrets without hardcoding them
  sops.templates."openclaw-env" = {
    content = ''
      SLACK_APP_TOKEN=${config.sops.placeholder."hex/openclaw/slack_app_token"}
      SLACK_BOT_TOKEN=${config.sops.placeholder."hex/openclaw/slack_bot_token"}
    '';
    owner = config.users.users.openclaw.name;
    group = config.users.users.openclaw.group;
    mode = "0400";
  };

  # Hardened systemd service for OpenClaw gateway
  systemd.services.openclaw = {
    description = "OpenClaw AI Assistant Gateway";
    documentation = [ "https://openclaw.ai" ];

    after = [
      "network.target"
      "tailscaled.service"
      "sops-nix.service"
    ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      # User and permissions
      User = config.users.users.openclaw.name;
      Group = config.users.users.openclaw.group;

      # Service execution
      Type = "simple";
      ExecStart = "${lib.getExe pkgs.openclaw} gateway --port 18789 --bind 127.0.0.1";
      Restart = "on-failure";
      RestartSec = "10s";

      # Load secrets as environment variables
      EnvironmentFile = config.sops.templates."openclaw-env".path;

      # Security hardening - filesystem
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      ReadWritePaths = [ "/var/lib/openclaw" ];

      # Security hardening - process
      NoNewPrivileges = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
      ProtectKernelTunables = true;
      ProtectKernelModules = true;
      ProtectControlGroups = true;
      RestrictNamespaces = true;
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      RestrictRealtime = true;

      # Resource limits
      MemoryMax = "2G";
      MemoryHigh = "1G";
      CPUQuota = "100%";

      # IPC security
      RemoveIPC = true;

      # Standard output/error
      StandardOutput = "journal";
      StandardError = "journal";
      SyslogIdentifier = "openclaw";
    };

    unitConfig = {
      StartLimitIntervalSec = 300;
      StartLimitBurst = 5;
    };
  };

  # Ensure the vault directory structure exists
  systemd.tmpfiles.rules = [
    "d /var/lib/openclaw 0750 openclaw openclaw -"
  ];
}
