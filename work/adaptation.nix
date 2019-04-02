{ config, pkgs, ... }:

let
  # This file contains non-public information.
  private = /etc/nixos/private.nix;

  #pidgin = pkgs.pidgin-with-plugins.override {
  #  plugins = [ pkgs.pidginsipe ];
  #};
in
{
  imports =
    [
      # For Android development
      ./android_container/docker.nix
    ] ++ (if builtins.pathExists private then [ private ] else []);

  networking.hostName = "nixos";

  # Virtualbox settings
  virtualisation.virtualbox.guest.enable = true;

  fileSystems."/virtualboxshare" = {
    fsType = "vboxsf";
    device = "transfer";
    options = [ "rw" ];
  };

  fileSystems."/mnt/as" = {
      device = "//10.239.124.56/nthorne";
      fsType = "cifs";
      options = let
        # this line prevents hanging on network split
        automount_opts = "rw,,uid=1000,gid=100,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

      in ["${automount_opts},credentials=/etc/nixos/smb-secrets"];
  };
  boot.tmpOnTmpfs = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    afuse
    arandr
    bashdb
    bedup
    ctags
    cppcheck
    gitRepo  # For the repo command.
    gnupg
    lnav
    minicom
    #pidgin
    sshfsFuse
    tmuxinator
    wget
    xdotool

    pkgs.pythonPackages.ipython
    #pkgs.pythonPackages.pylint
    pkgs.pythonPackages.virtualenv

    (import ./cppclean)
    (import ./ddoc)
    (import ./ntvim)

    # TODO: Can possibly drop this one.
    # Used in order to get deoplete up and running again, since
    # it requires a neovim python package that is not available
    # through Nix yet :/
    (python36.withPackages(ps: with ps; [ pip setuptools ]))
  ];

  services.udev.extraRules = ''
    # IHU
    SUBSYSTEM=="usb", ATTR{idVendor}=="8087", MODE="0666", GROUP="plugdev"
    '';

  services.cron = {
    enable = true;
    mailto = "niklas.thorne@aptiv.com";
    systemCronJobs = [
      "0 11 * * *      root    btrfs scrub start -q /dev/sda1"
    ];
  };

  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.nthorne.extraGroups =[ "wheel" "vboxsf" "docker" "dialout" ];

  # Allow ssh forwarding
  programs.ssh.forwardX11 = true;


}
