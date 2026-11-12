{
  pkgs,
  ...
}:
{
  home.file = {
    ".pi/agent/skills/excel-toolkit".source = ../copilot-cli/skills/excel-toolkit;
    ".pi/agent/skills/executing-plan".source = ../copilot-cli/skills/executing-plan;
    ".pi/agent/skills/grill-me".source = ../copilot-cli/skills/grill-me;
    ".pi/agent/skills/hunk".source = ../copilot-cli/skills/hunk;
    ".pi/agent/skills/nixos-host".source = ../copilot-cli/skills/nixos-host;
    ".pi/agent/skills/obsidian-vault".source = ../copilot-cli/skills/obsidian-vault;

    # Package settings
    ".pi/agent/extensions/pi-permission-system/config.json".source = ./permissions/config.json;
  };

  # Agent settings
  programs.pi-coding-agent = {
    enable = true;
    extraPackages = with pkgs; [
      nodejs

      #LSPs for pi-lens
      bash-language-server
      clang-tools
      htmlhint
      nixd
      pyright
      rust-analyzer
      yaml-language-server
    ];
    settings = {
      theme = "dark";
      packages = [
        "npm:@gotgenes/pi-permission-system"
        "npm:@juicesharp/rpiv-ask-user-question"
        "npm:@juicesharp/rpiv-todo"
        "npm:context-mode"
        "npm:pi-background-tasks"
        "npm:pi-hermes-memory"
        "npm:pi-lens"
        "npm:pi-system-prompt"
        "npm:pi-usage-meters"
        "npm:pi-web-access"

        # Under evaulation
        "npm:@narumitw/pi-plan-mode"
        "npm:pi-goal-x"
        "npm:pi-btw"
        "npm:pi-caveman"
      ];
    };
  };
}
