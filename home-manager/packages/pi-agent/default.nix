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
        "npm:bigpowers"
        "npm:context-mode"
        "npm:pi-background-tasks"
        "npm:pi-goal-x"
        "npm:pi-mcp-adapter"
        "npm:pi-memory"
        "npm:pi-subagents"
        "npm:pi-web-access"
      ];
    };
    models = {
      "providers" = {
        "ollama" = {
          "baseUrl" = "http://localhost:11434/v1";
          "api" = "openai-completions";
          "apiKey" = "ollama";
          "models" = [
            {
              "id" = "qwen3-coder";
            }
          ];
        };
      };
    };
  };
}
