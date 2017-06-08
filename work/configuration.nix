# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix

      ./proxy.nix
    ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  # networking.hostName = "devvm"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Virtualbox settings
  virtualisation.virtualbox.guest.enable = true;

  fileSystems."/virtualboxshare" = {
    fsType = "vboxsf";
    device = "transfer";
    options = [ "rw" ];
  };

  # Select internationalisation properties.
  i18n = {
    consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "sv-latin1";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [ 
    ag
    arandr
    bashdb
    ctags
    direnv
    dmenu
    dzen2
    firefox
    irssi
    lnav
    git
    gparted
    neovim
    shellcheck
    terminus_font
    tmux
    tmuxinator
    xdotool
    xsel
    zsh

    pkgs.pythonPackages.ipython
    pkgs.pythonPackages.pylint
    pkgs.pythonPackages.virtualenv

    (import ./ntvim)
  ];

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;
    layout = "se";
    windowManager.xmonad = {
      enable = true;
      enableContribAndExtras = true;
    };
    windowManager.default = "xmonad";
    displayManager = {
      slim = {
	enable = true;
	autoLogin = true;
	defaultUser = "nthorne";
      };
      sessionCommands = ''
      dropbox &
      '';
    };
    synaptics = {
      enable = true;
      accelFactor = "0.1";
      fingersMap = [ 1 3 2 ];
      palmDetect = true;
    };
  };

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.nthorne = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "vboxsf" ];
    createHome = true;
    home = "/home/nthorne";
    shell = "/run/current-system/sw/bin/zsh";
  };

  programs.zsh.enable = true;
  users.defaultUserShell = "/run/current-system/sw/bin/zsh";

  security.sudo.enable = true;

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.03";

  # :(
  nixpkgs.config.allowUnfree = true;
}
