{pkgs, ...}:
let
  theme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-medium.yaml";
  wallpaper = pkgs.runCommand "image.jpg" { } ''
    COLOR=$(${pkgs.yq}/bin/yq -r .palette.base00 ${theme})
    ${pkgs.imagemagick}/bin/magick -size 1920x1080 xc:$COLOR $out
  '';
in
{
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

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
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font Mono";
      };

      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };
  };
}
