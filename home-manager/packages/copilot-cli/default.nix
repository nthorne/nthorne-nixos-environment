{
  ...
}:
{
  home.file.".copilot/skills".source = ./skills;
  home.file.".copilot/copilot-instructions.md".source = ./instructions/instructions.md;

  programs.github-copilot-cli = {
    enable = true;
  };
}
