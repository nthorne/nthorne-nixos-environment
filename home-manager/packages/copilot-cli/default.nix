{
  pkgs,
  ...
}:
{
  home.packages = [
    pkgs.github-copilot-cli
  ];

  home.file.".copilot/skills".source = ./skills;
}
