{
  flake-inputs,
  ...
}: let
in {
  programs.opencode = {
    enable = true;
    settings = {
      share = "disabled";
      autoupdate = false;
      enabled_providers = [ "github-copilot" ];

      mcp = {
        sequentialthinking = {
          type = "local";
          enabled = true;
          command = [ "podman" "run" "--rm" "-i" "mcp/sequentialthinking" ];
        };
        markitdown = {
          type = "local";
          enabled = true;
          command = [ "podman" "run" "--rm" "-i" "mcp/markitdown" ];
        };
        memory = {
          type = "local";
          enabled = true;
          command = [ "podman" "run" "-i" "-v" "agent-memory:/app/dist" "--rm" "mcp/memory" ];
        };
        nixos = {
          type = "local";
          enabled = true;
          command = [ "nix" "run" "github:utensils/mcp-nixos" "--" ];
        };
      };
    };
  };

  home.file.".config/opencode/AGENTS.md".source = ./AGENTS.md;
  home.file.".config/opencode/agent".source = ./agent;
  home.file.".config/opencode/command".source = ./command;
  home.file.".config/opencode/skills".source = ../copilot-cli/skills;
}
