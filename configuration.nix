# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{pkgs, ...}: let
  theme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
  wallpaper = pkgs.runCommand "image.png" {} ''
    COLOR=$(${pkgs.yq}/bin/yq -r .palette.base00 ${theme})
    ${pkgs.imagemagick}/bin/magick -size 1920x1080 xc:$COLOR $out
  '';
in {
  nixpkgs.config = {
    # :(
    allowUnfree = true;
    oraclejdk.accept_license = true;
  };

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    age
    git
    git-agecrypt
    terminus_font
    unzip

    polkit
    polkit_gnome
    sops
  ];

  fonts.packages = with pkgs; [jetbrains-mono];

  users.users.root.packages = with pkgs; [vim];

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

  # Enable the OpenSSH daemon.
  #services.openssh.enable = true;

  # Enable power management
  #services.tlp.enable = true;

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --asterisks --remember --remember-user-session --sessions ${pkgs.hyprland}/bin/Hyprland";
      };
    };
  };
  programs.hyprland = {
    enable = true;
    withUWSM = true;
    xwayland.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.nthorne = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = ["wheel"];
    createHome = true;
    home = "/home/nthorne";
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

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

  nix.optimise.automatic = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 21d";
  };

  services.gnome.gnome-keyring.enable = true;

  # Needed for e.g. privleged operations in Clion
  security.polkit.enable = true;
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = ["graphical-session.target"];
      wants = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  stylix = {
    enable = true;
    image = wallpaper;
    base16Scheme = theme;

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Original-Ice";
    };

    fonts = {
      serif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Serif";
      };

      sansSerif = {
        package = pkgs.dejavu_fonts;
        name = "DejaVu Sans";
      };

      monospace = {
        package = pkgs.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };

      emoji = {
        package = pkgs.noto-fonts-emoji;
        name = "Noto Color Emoji";
      };
    };
  };

  # Get completions for system packages such as systemd
  environment.pathsToLink = ["/share/zsh"];
}
