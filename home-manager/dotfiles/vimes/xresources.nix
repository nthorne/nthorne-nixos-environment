{ pkgs, ...}:
{
  home.file = {
    ".Xresources".source = ./.Xresources;
  };
}
