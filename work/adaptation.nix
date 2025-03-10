{
  config,
  pkgs,
  unstable,
  lib,
  ...
}: let
  # TODO:
  #
  # * docker0 interface - inet -> 10.10.2.54 (not 172.17.0.1). Not set up; wonder where it got pulled from (daemon.json:{"bip":"10.10.254.1/24"})
  ethernetDevice = "enp0s13f0u4u4";
in {
  # Don't require ethernet to be connected when booting
  systemd.services = {
    "network-link-${ethernetDevice}".wantedBy = lib.mkForce [];
    "network-addresses-${ethernetDevice}".wantedBy = lib.mkForce [];
  };

  # Start the driver at boot
  systemd.services.fprintd = {
    wantedBy = ["multi-user.target"];
    serviceConfig.Type = "simple";
  };

  # Install the driver
  services.fprintd = {
    enable = true;
  };

  # Seems to be needed for parallel PAM sessions (fingerprint OR password)
  security.pam.services.hyprlock = {};

  # Enable fscrypt for home directory encryption
  security.pam.enableFscrypt = true;
  # NOTE: I NEED to login with password to descrypt my home directory.
  security.pam.services.greetd.fprintAuth = false;

  # PAM fails to lock protector in memory, causing unlock to fail, so we
  # increase the memlock limit to infinity.
  systemd.extraConfig = ''
    DefaultLimitMEMLOCK=infinity
  '';

  # This sets memlock limits for all users to "unlimited"
  security.pam.loginLimits = [
    {
      domain = "*";
      item = "memlock";
      type = "-";
      value = "unlimited";
    }
  ];

  # Have the home-manager service restart on failure, since it needs
  # to have my home directory decrypted in order to exit successfully.
  # Setting After etc does not work since we only append to that list.
  # Wait 10s between restarts, and allow 30 restarts within a 5 minute window.
  systemd.services."home-manager-nthorne".serviceConfig = {
    Restart = "on-failure";
    RestartSec = "10s";
    StartLimitIntervalSec = "300";
    StartLimitBurst = 30;
  };

  boot.kernel.sysctl."kernel.ftrace_enabled" = true;
  boot.kernel.sysctl."kernel.perf_event_paranoid" = 1;
  boot.kernel.sysctl."kernel.kptr_restrict" = true;

  virtualisation = {
    podman = {
      enable = true;
    };
    docker.enable = true;
  };

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = ["nthorne"];

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    hostName = "vimes";

    interfaces = {
      enp0s13f0u4u4.useDHCP = true;
      wlp0s20f3.useDHCP = true;
    };

    nat = {
      enable = true;
      internalInterfaces = ["ve-*"];
      # Wired at office.
      externalInterface = "wlp0s20f3";
    };

    networkmanager = {
      enable = true;
      wifi.powersave = false;
    };

    useDHCP = false;

    wireless = {
      enable = true;
      userControlled.enable = true;
    };
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    afuse
    fscrypt-experimental
    gnupg
    sshfs-fuse
  ];

  boot = {
    kernelModules = [
      "nbd"
      "uvcvideo"
      "akvcam"
      "v4l2loopback"
    ];
    tmp.useTmpfs = true;
    extraModulePackages = [config.boot.kernelPackages.v4l2loopback.out];
  };

  # Set initial kernel module settings
  boot.extraModprobeConfig = ''
    # exclusive_caps: Skype, Zoom, Teams etc. will only show device when actually streaming
    # card_label: Name of virtual camera, how it'll show up in Skype, Zoom, Teams
    # https://github.com/umlaeute/v4l2loopback
    options v4l2loopback devices=1 video_nr=10 card_label="OBS Cam" exclusive_caps=1
  '';

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.nthorne.extraGroups = [
    "wheel"
    "docker"
    "dialout"
    "disk"
    "audio"
  ];
  users.extraGroups.networkmanager.members = ["nthorne"];

  hardware.nvidia = {
    # Keep using the closed source, proprietary driver.
    open = false;
    prime = {
      offload.enable = true;

      # Bus ID of the Intel GPU. VGA controller found with lspci
      intelBusId = "PCI:0:2:0";

      # Bus ID of the NVIDIA GPU. 3D controller found with lspci
      nvidiaBusId = "PCI:1:0:0";
    };
  };

  # ^^

  # Not sure about this one
  hardware.nvidia.modesetting.enable = true;
  services = {
    xserver.videoDrivers = [
      "nvidia"
      "intel"
      "modesetting"
      "displaylink"
    ];
  };

  # https://discourse.nixos.org/t/external-monitors-not-working-dell-xps/1799/7
  # dropped uvcvideo from this list, since I do want a webcam..
  boot.blacklistedKernelModules = [
    "nouveau"
    "rivafb"
    "nvidiafb"
    "rivatv"
    "nv"
  ];
  # ^^

  # Unless this one, (and no nvidia driver), kitty refuses to start.
  hardware.graphics.enable = true;

  # Needed for cargo to be able to pull from private Github repositories
  programs.ssh = {
    forwardX11 = true;
    startAgent = true;
  };

  services.ollama = {
    enable = true;
    acceleration = "cuda";
    environmentVariables = {
      OLLAMA_ORIGINS = "app://obsidian.md*";
      CUDA_VISIBLE_DEVICES = "0,1";
    };
    package = unstable.ollama;
  };

  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
    experimental-features = nix-command flakes
  '';
}
