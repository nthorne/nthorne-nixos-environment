# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  # The adaptation file details configuration items that are unique
  # to the particular target (e.g. guest additions for work vm).
  adaptation = /etc/nixos/adaptation.nix;

  unstableTarball =
    fetchTarball
      https://github.com/NixOS/nixpkgs-channels/archive/nixos-unstable.tar.gz;
in
{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
    ] ++ (if builtins.pathExists adaptation then [ adaptation ] else []);

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  # networking.hostName = "nixlaptop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Select internationalisation properties.
  console = {
    font = "Lat2-Terminus16";
    keyMap = "sv-latin1";
  };
  i18n.defaultLocale = "en_US.UTF-8";

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  nixpkgs.config = {
    packageOverrides = pkgs: {
      unstable = import unstableTarball {
        config = config.nixpkgs.config;
      };
    };
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    ag
    alsaUtils
    direnv
    dmenu
    dzen2
    evince
    fasd
    file
    # We'll follow unstable Firefox for now, while I've pinned the NixOS channel..
    unstable.firefox
    git
    gparted
    htop
    hyperfine
    irssi
    unstable.neovim
    neovim-remote
    qalculate-gtk
    ranger
    shellcheck
    terminus_font
    tldr
    tree
    tmux
    unzip
    xsel
    yank
    zsh
  ];

  # List services that you want to enable:
  services.nixosManual.enable = true;

  sound.enable = true;

  # Enable the OpenSSH daemon.
  #services.openssh.enable = true;

  # Enable power management
  #services.tlp.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "se";
    # Don't use xterm as a desktop manager..
    desktopManager.xterm.enable = false;
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
    displayManager = {
      defaultSession = "none+xmonad";
      autoLogin = {
        enable = true;
        user = "nthorne";
      };
      lightdm = {
	enable = true;
      };
    };
    synaptics = {
      enable = true;
      accelFactor = "0.1";
      fingersMap = [ 1 3 2 ];
      palmDetect = true;
    };
  };


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.nthorne = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" ];
    createHome = true;
    home = "/home/nthorne";
    shell = "/run/current-system/sw/bin/zsh";
  };

  programs.zsh.enable = true;
  users.defaultUserShell = "/run/current-system/sw/bin/zsh";

  security.sudo.enable = true;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "20.09";

  # :(
  nixpkgs.config = {
    allowUnfree = true;
    oraclejdk.accept_license = true;
  };
  # Enable this one when building derivations intented for NixPkgs
  #nix.useSandbox = true;
}
