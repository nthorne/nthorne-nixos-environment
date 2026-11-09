{ pkgs, ... }:
{
  nixpkgs.config = {
    # :(
    allowUnfree = true;
  };

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

  users = {
    users.root.packages = with pkgs; [ vim ];

    users.nthorne = {
      isNormalUser = true;
      uid = 1000;
      extraGroups = [ "wheel" ];
      createHome = true;
      home = "/home/nthorne";
      shell = pkgs.zsh;
    };
    defaultUserShell = pkgs.zsh;
  };

  console = {
    font = "Lat2-Terminus16";
    keyMap = "sv-latin1";
  };
  i18n.defaultLocale = "en_US.UTF-8";

  time.timeZone = "Europe/Stockholm";

  documentation.nixos.enable = true;

  programs.zsh.enable = true;
  security.sudo.enable = true;

  system = {
    stateVersion = "22.05";

    # Fix for getting NIX_PATH to work after having deleted channels
    systemBuilderCommands = ''
      ln -sv ${pkgs.path} $out/nixpkgs
    '';
  };

  nix = {
    nixPath = [ "nixpkgs=/run/current-system/nixpkgs" ];

    optimise.automatic = true;

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 21d";
    };
  };

  services.gnome.gnome-keyring.enable = true;

  # Needed for e.g. privileged operations in Clion
  security.polkit.enable = true;
  systemd = {
    user.services.polkit-gnome-authentication-agent-1 = {
      description = "polkit-gnome-authentication-agent-1";
      wantedBy = [ "graphical-session.target" ];
      wants = [ "graphical-session.target" ];
      after = [ "graphical-session.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
        Restart = "on-failure";
        RestartSec = 1;
        TimeoutStopSec = 10;
      };
    };
  };

  # Get completions for system packages such as systemd
  environment = {
    pathsToLink = [ "/share/zsh" ];
    variables = {
      # Fix for GTK apps (e.g. ghostty) not detecting dead keys (e.g. tilde) properly
      GTK_IM_MODULE = "simple";
    };
  };
}
