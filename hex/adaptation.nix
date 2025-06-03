{...}: let
  private = /etc/nixos/private.nix;
in {
  imports =
    []
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
      };
    };
  };

  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';
}
