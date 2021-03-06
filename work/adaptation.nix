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
      ./qcomm-container/docker.nix
    ] ++ (if builtins.pathExists private then [ private ] else []);

  boot.kernelModules = [ "nbd" ];

  networking.hostName = "nixos";

  # Broken on 19.03 using BTRFS, apparently :(
  # Virtualbox settings
  virtualisation.virtualbox.guest.enable = true;

  fileSystems."/virtualboxshare" = {
    fsType = "vboxsf";
    device = "transfer";
    options = [ "rw,uid=1000,gid=100,nofail" ];
  };

  fileSystems."/mnt/external" = {
      fsType = "ext4";
      device = "/dev/sdb1";
      options = [ "rw,noauto,user,exec" ];

  };

  #fileSystems."/mnt/as" = {
  #    device = "//10.239.124.56/nthorne";
  #    fsType = "cifs";
  #    options = let
  #      # this line prevents hanging on network split
  #      automount_opts = "rw,,uid=1000,gid=100,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

  #    in ["${automount_opts},credentials=/etc/nixos/smb-secrets"];
  #};
  boot.tmpOnTmpfs = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    afuse
    arandr
    bashdb
    bedup
    compsize
    ctags
    cppcheck
    duperemove
    gnupg
    kdiff3
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

  # 05c6 is the IHU5 dev board, 18d1 is a newer iteration; 0403 is my Galaxy S9.
  services.udev.extraRules = ''
    # IHU
    SUBSYSTEM=="usb", ATTR{idVendor}=="8087", MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTR{idVendor}=="05c6", MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666", GROUP="plugdev"
    SUBSYSTEM=="usb", ATTR{idVendor}=="0403", MODE="0666", GROUP="plugdev"
    '';

  services.cron = {
    enable = true;
    systemCronJobs = [
      "00 20 * * *      root    btrfs scrub start -q /dev/sda1"
      "00 23 * * *      root    duperemove -dr --hashfile=/var/cache/dedupe-db/duperemove.db /home/nthorne/.ccache /home/nthorne/work/sem /home/nthorne/work/ihu > /tmp/dupremove.log"
      "00 11 * * *      nthorne /home/nthorne/bin/backup.sh"
      "00 19 * * *      nthorne /home/nthorne/bin/docker-prune.sh"
    ];
  };

  security.sudo.extraConfig = ''
    %wheel      ALL=(ALL:ALL) NOPASSWD: ${pkgs.bedup}/bin/bedup
    %wheel      ALL=(ALL:ALL) NOPASSWD: ${pkgs.duperemove}/bin/duperemove
    %wheel      ALL=(ALL:ALL) NOPASSWD: /run/current-system/sw/bin/btrfs
    %wheel      ALL=(ALL:ALL) NOPASSWD: /run/current-system/sw/bin/mount
    %wheel      ALL=(ALL:ALL) NOPASSWD: ${pkgs.qemu}/bin/qemu-nbd
    %wheel      ALL=(ALL:ALL) NOPASSWD: ${pkgs.compsize}/bin/compsize
    '';
  # Enable the KDE Desktop Environment.
  # services.xserver.displayManager.sddm.enable = true;
  # services.xserver.desktopManager.plasma5.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.nthorne.extraGroups =[ "wheel" "vboxsf" "docker" "dialout" "disk" ];

  # Allow ssh forwarding
  programs.ssh.forwardX11 = true;

  # allow for e.g. forwarding via adb to target
  networking.firewall.allowedTCPPorts = [ 8888 ];
  services.openssh = {
    enable = true;
    gatewayPorts = "yes";
    openFirewall = true;
  };
}
