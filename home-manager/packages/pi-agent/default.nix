{
  pkgs,
  ...
}:
{
  home.file.".pi/agent/skills/caveman".source = ../copilot-cli/skills/caveman;
  home.file.".pi/agent/skills/excel-toolkit".source = ../copilot-cli/skills/excel-toolkit;
  home.file.".pi/agent/skills/executing-plan".source = ../copilot-cli/skills/executing-plan;
  home.file.".pi/agent/skills/grill-me".source = ../copilot-cli/skills/grill-me;
  home.file.".pi/agent/skills/hunk".source = ../copilot-cli/skills/hunk;
  home.file.".pi/agent/skills/nixos-host".source = ../copilot-cli/skills/nixos-host;
  home.file.".pi/agent/skills/obsidian-vault".source = ../copilot-cli/skills/obsidian-vault;

  # Package settings
  home.file.".pi/agent/extensions/pi-permission-system/config.json".source = ./permissions/config.json;

  # Agent settings
  programs.pi-coding-agent = {
    enable = true;
    extraPackages = [ pkgs.nodejs ];
    settings = {
      theme = "dark";
      packages = [
        "npm:@gotgenes/pi-permission-system"
        "npm:@juicesharp/rpiv-ask-user-question"
        "npm:@juicesharp/rpiv-todo"
        "npm:@narumitw/pi-plan-mode"
        "npm:context-mode"
        "npm:pi-background-tasks"
        "npm:pi-goal-x"
        "npm:pi-hermes-memory"
        "npm:pi-system-prompt"
        "npm:pi-usage-meters"
        "npm:pi-web-access"
      ];
    };
  };
}
