{
  config,
  pkgs,
  unstable,
  lib,
  ...
}:

let
  # TODO:
  #
  # * Full disk encryption, or is home enough?
  # * docker0 interface - inet -> 10.10.2.54 (not 172.17.0.1). Not set up; wonder where it got pulled from (daemon.json:{"bip":"10.10.254.1/24"})

  ethernetDevice = "enp0s13f0u4u4";
in
{
  # Don't require ethernet to be connected when booting
  systemd.services = {
    "network-link-${ethernetDevice}".wantedBy = lib.mkForce [ ];
    "network-addresses-${ethernetDevice}".wantedBy = lib.mkForce [ ];
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
  users.extraGroups.vboxusers.members = [ "nthorne" ];

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
      internalInterfaces = [ "ve-*" ];
      # Wired at office.
      externalInterface = "wlp0s20f3";
    };

    networkmanager.enable = true;

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
    gnupg
    sshfs-fuse

    # Something, somewhere seems to want python3. Perhaps
    # a zsh plugin or something?
    (python310.withPackages (
      ps: with ps; [
        pip
        setuptools
      ]
    ))
  ];

  boot = {
    kernelModules = [
      "nbd"
      "uvcvideo"
      "akvcam"
      "v4l2loopback"
    ];
    tmp.useTmpfs = true;
    extraModulePackages = [ config.boot.kernelPackages.v4l2loopback.out ];
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
  users.extraGroups.networkmanager.members = [ "nthorne" ];

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

  # Skip password for slock..
  security.sudo.extraRules = [
    {
      users = [ "nthorne" ];
      commands = [
        {
          command = "/etc/profiles/per-user/nthorne/bin/slock";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

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
