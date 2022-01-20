{ pkgs, ...}:
{
  home.file = {
    ".conkyrc".source = ./.conkyrc;
  };
}
