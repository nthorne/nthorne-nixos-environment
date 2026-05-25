{
  config,
  pkgs,
  lib,
  ...
}: let
  theme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
  wallpaper = pkgs.runCommand "image.jpg" {} ''
    COLOR=$(${pkgs.yq}/bin/yq -r .palette.base00 ${theme})
    ${pkgs.imagemagick}/bin/magick -size 1920x1080 xc:$COLOR $out
  '';
in 
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
git
tmux
vim
  ];

  environment.pathsToLink = ["/share/applications" "/share/xdg-desktop-portal"];
  nixpkgs.config = {
    allowUnfree = true;
};

  # Define a user account. Don't forget to set a password with ‘passwd’.
   users.extraUsers.nthorne = {
    isNormalUser = true;
    uid = 1001;
    extraGroups = ["wheel"];
    createHome = true;
    home = "/home/nthorne";
    shell = pkgs.zsh;
  };

  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;

  stylix = {
    enable = true;
    image = wallpaper;
    base16Scheme = theme;

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Original-Ice";
      size = 24;
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
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };
  };
}
