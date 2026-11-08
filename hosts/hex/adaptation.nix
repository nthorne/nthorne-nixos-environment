{config, ...}: let
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

    settings.model.default = "deepseek/deepseek-v4-flash";

    # Secrets: rendered from sops-nix into a DOTENV file
    environmentFiles = [ config.sops.templates."hermes-env".path ];
  };

  sops = {
    # Each sops secret under the "hermes/" prefix in secrets.yaml
    secrets = {
      "hex/hermes/open_router_api_key" = { };
      "hex/hermes/discord_bot_token" = { };
    };

    templates."hermes-env" = {
      owner = "hermes";
      group = "hermes";
      mode = "0400";
      content = ''
        OPENROUTER_API_KEY=${config.sops.placeholder."hex/hermes/open_router_api_key"}
        DISCORD_BOT_TOKEN=${config.sops.placeholder."hex/hermes/discord_bot_token"}
      '';
    };
  };
}
