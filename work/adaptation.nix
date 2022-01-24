{ config, pkgs, ... }:

let
  # TODO:
  #
  # * Virtualbox
  # * Vagrant
  # * Screen lock (automatic?) - Perhaps drop slock. Again, maybe not. dm-tool lock
  #     seems to be ignoring my wish to not power save screens :/
  # * Docker
  # * Full disk encryption, or is home enough?
  # * Create nvidia-offload wrappers for teams and slack
  # * Perhaps default display settings, at least when undocked.
  # * Clean up and push this config, together with a skeleton ./private.nix
  # * DisplayLink/evdi might work better in newer kernel versions, *but* evdi is currently broken,
  #   so I can't really switch to boot.kernelPackages=pkgs.linuxPackages_latest;
  #     REF: https://nixos.wiki/wiki/Linux_kernel
  #     REF: https://bugs.archlinux.org/task/70135
  #     REF: https://github.com/NixOS/nixpkgs/issues/78403
  #     REF: https://github.com/NixOS/nixpkgs/issues/74698
  # * Refactor the home/work scheme to a host based one instead.
  # * Samba mount for diskmaskinen
  # * Samba mount for netcleantech.local/dfs
  #
  # DOING:

  # This file contains non-public information.

  # Needed for running e.g. slack and teams
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
in
{
  imports =
    [
    ] ++ (if builtins.pathExists ./private.nix then [ ./private.nix ] else []);

  # EVALUATION:
  #
  # I needed this one to get a IPv4 on wired. Why?!
  # +group
  #networking.networkmanager.enable = true;
  #users.extraGroups.networkmanager.members = [ "nthorne" ];

  virtualisation.virtualbox.host.enable = true;
  users.extraGroups.vboxusers.members = [ "nthorne" ];

  # ^^

  virtualisation.docker.enable = true;

  # Below is needed for webcam, and to get teams to be able to select
  # audio sources properly. uvcvideo needs to be modprobed, and I need
  # to be in the audio group as well.
  services.uvcvideo.dynctrl = {
    enable = true;
    packages = [ pkgs.tiscamera ];
  };
  hardware.pulseaudio.enable = true;
  hardware.pulseaudio.support32Bit = true;
  nixpkgs.config.pulseaudio = true;

  hardware.bluetooth.enable = true;
  services.blueman.enable = true;


  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.useDHCP = false;
  networking.interfaces.enp0s13f0u4u4.useDHCP = true;
  networking.interfaces.wlp0s20f3.useDHCP = true;
  # network specific settings are in private.nix
  networking.wireless.enable = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    afuse
    arandr
    bedup
    compsize
    duperemove
    gnupg
    sshfsFuse

    # Something, somewhere seems to want python3. Perhaps
    # a zsh plugin or something?
    (python37.withPackages(ps: with ps; [ pip setuptools ]))

    # TODO: Write wrappers for slack and teams
    nvidia-offload
  ];

  boot = {
    # TODO: uvcvideo should be needed for webcam
    kernelModules = [ "nbd" "uvcvideo" ];
    tmpOnTmpfs = true;
  };

  networking.hostName = "vimes";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.nthorne.extraGroups =[ "wheel" "docker" "dialout" "disk" "audio" ];

  hardware.nvidia.prime = {
    offload.enable = true;

    # Bus ID of the Intel GPU. VGA controller found with lspci
    intelBusId = "PCI:0:2:0";

    # Bus ID of the NVIDIA GPU. 3D controller found with lspci
    nvidiaBusId = "PCI:1:0:0";
  };

  # ^^

  # Not sure about this one
  hardware.nvidia.modesetting.enable = true;
  # Worked decently without the nvidia driver
  services.xserver = {
    videoDrivers = [ "nvidia" "intel" "modesetting" "displaylink" ];

    displayManager = {
      autoLogin = {
        enable = false;
        user = "nthorne";
      };

      # https://linuxreviews.org/HOWTO_turn_Screensavers_and_Monitor_Power_Saving_on_and_off
      sessionCommands = ''
        xset s off
        xset -dpms
        '';
    };
  };

  # Skip password for slock..
  security.sudo.extraRules = [
    {
      users = [ "nthorne" ];
      commands = [ {command = "/home/nthorne/.nix-profile/bin/slock" ; options = [ "NOPASSWD" ]; } ] ;
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
  hardware.opengl.enable = true;


  # Allow ssh forwarding
  programs.ssh.forwardX11 = true;

  nix.extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      '';
}
