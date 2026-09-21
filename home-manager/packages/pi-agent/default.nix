{
  pkgs,
  ...
}:
{
  home.file.".pi/agent/skills".source = ../copilot-cli/skills;

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
        "npm:@narumitw/pi-btw"
        "npm:@narumitw/pi-plan-mode"
        "npm:context-mode"
        "npm:pi-background-tasks"
        "npm:pi-goal-x"
        "npm:pi-hermes-memory"
        "npm:pi-mcp-adapter"
        "npm:pi-subagents"
        "npm:pi-system-prompt"
        "npm:pi-web-access"
      ];
    };
  };
}
