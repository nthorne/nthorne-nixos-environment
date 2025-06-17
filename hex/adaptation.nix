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

  environment.systemPackages = with pkgs; [
    age
    sops
  ];

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  services.displayManager.autoLogin = {
    enable = true;
    user = "nthorne";
  };

  services.tailscale.enable = true;

  hardware.graphics.enable = true;

  users.extraUsers.nthorne.extraGroups = [
    "wheel"
    "docker"
    "dialout"
  ];

  # Systemd socket unit
  systemd.sockets.open-webui = {
    enable = true;
    wantedBy = ["sockets.target"];
    socketConfig.ListenStream = 8080;
  };

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
        flags = ["--all" "--filter"];
      };
    };
    docker.enable = true;

    oci-containers = {
      backend = "podman";
      containers = {
        openwebui = {
          image = "ghcr.io/open-webui/open-webui:main";
          ports = ["8080:8080"];
          volumes = [
            "openwebui:/app/backend/data"
          ];
          autoStart = true;

          extraOptions = ["--network=host"];
        };
        searxng = {
          image = "searxng/searxng";
          volumes = [
            "searxng:/etc/searxng"
          ];
          autoStart = true;

          extraOptions = ["--network=host"];

          environment = {
            BIND_ADDRESS = "0.0.0.0:8081";
            INSTANCE_NAME = "hex";
          };
        };
      };
    };
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
}
