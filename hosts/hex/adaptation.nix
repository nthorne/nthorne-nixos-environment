{config, pkgs, ...}: let
  private = /etc/nixos/private.nix;
in {
  imports =
    [
      ./wallabag.nix
    ]
    ++ (
      if builtins.pathExists private
      then [private]
      else []
    );

  networking.hostName = "hex";
  networking.networkmanager.enable = true;

  boot.loader = {
    # Use the GRUB 2 boot loader.
    grub = {
      enable = true;

      # Define on which hard drive you want to install Grub.
      device = "/dev/sda"; # or "nodev" for efi only
    };
  };

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.displayManager.autoLogin = {
    enable = true;
    user = "nthorne";
  };

  services.tailscale.enable = true;

  hardware.graphics.enable = true;

  users.users.nthorne.extraGroups = [
    "wheel"
    "docker"
    "dialout"
  ];

  # services.hermes-agent creates the hermes user; this only adds a group to
  # it. systemd-journal lets the agent read `journalctl -u hermes-agent`
  # itself instead of asking for log excerpts.
  users.users.hermes.extraGroups = [ "systemd-journal" ];

  # Systemd socket unit
  # systemd.sockets.open-webui = {
  #   enable = true;
  #   wantedBy = ["sockets.target"];
  #   socketConfig.ListenStream = 8080;
  # };

  # Enable container name DNS for all Podman networks.
  networking.firewall.interfaces = let
    matchAll =
      if !config.networking.nftables.enable
      then "podman+"
      else "podman*";
  in {
    "${matchAll}".allowedUDPPorts = [53];

    # Hermes webapp. The listener binds 0.0.0.0 (the only non-loopback bind
    # the webapp accepts), so the firewall is what keeps it tailnet-only.
    tailscale0.allowedTCPPorts = [ 9120 ];
  };

  virtualisation = {
    podman = {
      enable = true;
      autoPrune = {
        enable = true;
        flags = ["--all"];
      };
    };
    docker.enable = true;

    oci-containers = {
      backend = "podman";
      containers = {
          # openwebui = {
          #   image = "ghcr.io/open-webui/open-webui:main";
          #   ports = ["8080:8080"];
          #   volumes = [
          #     "openwebui:/app/backend/data"
          #   ];
          #   autoStart = true;

          #   extraOptions = ["--network=host"];
          # };
          # searxng = {
          #   image = "searxng/searxng";
          #   volumes = [
          #     "searxng:/etc/searxng"
          #   ];
          #   autoStart = true;

          #   extraOptions = ["--network=host"];

          #   environment = {
          #     BIND_ADDRESS = "0.0.0.0:8081";
          #     INSTANCE_NAME = "hex";
          #   };
          # };
      };
    };
  };

  programs.mosh.enable = true;

  # ── Hermes Agent ───────────────────────────────────────────────────────
  # https://hermes-agent.nousresearch.com/docs/getting-started/nix-setup
  services.hermes-agent = {
    enable = true;
    addToSystemPackages = true;
    extraDependencyGroups = [ "messaging" ];

    # git needs an ssh client for git+ssh remotes; the hermes service PATH
    # carries none of its own.
    extraPackages = [ pkgs.openssh ];

    settings = {
      # Matches what the per-user install runs today, so the config merge
      # during the migration does not silently change the model.
      model.default = "deepseek/deepseek-v4.1-flash-1017";

      # Browser-hosted web app, served by the gateway's own HTTP listener.
      # The webapp accepts only a loopback or a wildcard bind; a wildcard
      # engages the dashboard sign-in gate, which the basic-auth provider
      # below satisfies from sops. The firewall limits the port to
      # tailscale0, so it is reachable at http://<tailnet-name>:9120 from
      # the tailnet and nowhere else.
      webapp = {
        enabled = true;
        host = "0.0.0.0";
        port = 9120;
      };
    };

    # Secrets: rendered from sops-nix into a DOTENV file
    environmentFiles = [ config.sops.templates."hermes-env".path ];
  };

  sops = {
    # Each sops secret under the "hermes/" prefix in secrets.yaml
    secrets = {
      "hex/hermes/open_router_api_key" = { };
      "hex/hermes/discord_bot_token" = { };
      # Basic-auth credentials for the webapp's sign-in gate
      "hex/hermes/dashboard_password_hash" = { };
      "hex/hermes/dashboard_secret" = { };
      # Fine-grained PAT, Pull requests: write only, for `gh pr create`
      "hex/hermes/github_token" = { };
    };

    templates."hermes-env" = {
      owner = "hermes";
      group = "hermes";
      mode = "0400";
      content = ''
        OPENROUTER_API_KEY=${config.sops.placeholder."hex/hermes/open_router_api_key"}
        DISCORD_BOT_TOKEN=${config.sops.placeholder."hex/hermes/discord_bot_token"}
        # Without an allowlist the gateway connects and then denies everyone.
        DISCORD_ALLOWED_USERS=1402392313132482733
        HERMES_DASHBOARD_BASIC_AUTH_USERNAME=nthorne
        HERMES_DASHBOARD_BASIC_AUTH_PASSWORD_HASH=${config.sops.placeholder."hex/hermes/dashboard_password_hash"}
        HERMES_DASHBOARD_BASIC_AUTH_SECRET=${config.sops.placeholder."hex/hermes/dashboard_secret"}
        # gh reads GH_TOKEN itself; the PAT is scoped to Pull requests: write
        GH_TOKEN=${config.sops.placeholder."hex/hermes/github_token"}
      '';
    };
  };
}
