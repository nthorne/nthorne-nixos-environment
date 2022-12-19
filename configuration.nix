# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  # TOOD(flakify): Drop this
  # The adaptation file details configuration items that are unique
  # to the particular target (e.g. guest additions for work vm).
  #adaptation = /etc/nixos/adaptation.nix;
in
{
  # TOOD(flakify): Drop this
  #imports =
  #  [ # Include the results of the hardware scan.
  #    /etc/nixos/hardware-configuration.nix
  #  ] ++ (if builtins.pathExists adaptation then [ adaptation ] else []);

  nixpkgs.config = {
    # :(
    allowUnfree = true;
    oraclejdk.accept_license = true;
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    alsaUtils
    dmenu
    dzen2
    git
    terminus_font
    unzip
    zsh
  ];

  fonts.fonts = with pkgs; [
    jetbrains-mono
  ];

  users.users.root.packages = with pkgs;
  [
    vim
  ];

  # Select internationalisation properties.
  console = {
    font = "Lat2-Terminus16";
    keyMap = "sv-latin1";
  };
  i18n.defaultLocale = "en_US.UTF-8";

  # Set your time zone.
  time.timeZone = "Europe/Stockholm";

  # List services that you want to enable:
  documentation.nixos.enable = true;

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

  system = {
    # The NixOS release to be compatible with for stateful data such as databases.
    stateVersion = "21.11";

    # TODO(flakify): This is impure. Drop it.
    # This snapshots configuration.nix into /run/current-system/configuration.nix
    # (excluding imports, unfortunately).
    # copySystemConfiguration = true;
  };

  # Enable this one when building derivations intented for NixPkgs
  #nix.useSandbox = true;
}
