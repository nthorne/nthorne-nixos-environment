{
  nixos-wsl,
  pkgs,
  ...
}:
{
  imports = [
    nixos-wsl.nixosModules.default
  ];

  networking.hostName = "mort";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    git
    tmux
  ];

  # nvim comes from nixvim through Home Manager; keep a plain vim for root so
  # `sudo vim /etc/nixos/...` still works.
  users.users.root.packages = with pkgs; [ vim ];

  environment.pathsToLink = [
    "/share/applications"
    "/share/xdg-desktop-portal"
  ];
  nixpkgs.config = {
    allowUnfree = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.nthorne = {
    isNormalUser = true;
    uid = 1001;
    extraGroups = [ "wheel" ];
    createHome = true;
    home = "/home/nthorne";
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  nix.optimise.automatic = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 21d";
  };

  time.timeZone = "Europe/Stockholm";

  programs.nix-ld.enable = true;

  wsl = {
    enable = true;
    defaultUser = "nthorne";
    interop.register = true;
  };

  system.stateVersion = "22.05";
}
