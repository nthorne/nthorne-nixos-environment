# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:
{
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
    libinput.touchpad = {
      disableWhileTyping = true;
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
    stateVersion = "22.05";

    # Fix for getting NIX_PATH to work after having deleted channels
    extraSystemBuilderCmds = ''
      ln -sv ${pkgs.path} $out/nixpkgs
    '';
  };

  nix.nixPath = ["nixpkgs=/run/current-system/nixpkgs"];

  # Enable this one when building derivations intented for NixPkgs
  #nix.useSandbox = true;

  nix.settings.auto-optimise-store = true;

  # For VS Code
  services.gnome.gnome-keyring.enable = true;
}
