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
      enabled_providers = [ "github-copilot" "ollama" ];
      model = "github-copilot/claude-sonnet-4.6";
      small_model = "github-copilot/gpt-5-mini";

       provider = {
           ollama = {
             npm = "@ai-sdk/openai-compatible";
             name = "Ollama";
             options = {
               baseURL = "http://localhost:11434/v1";
             };
           };
       };

      mcp = {
        github_grep = {
          type = "remote";
          url = "https://mcp.grep.app";
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
        sequentialthinking = {
          type = "local";
          enabled = true;
          command = [ "podman" "run" "--rm" "-i" "mcp/sequentialthinking" ];
        };
      };
    };
  };

  home.file.".config/opencode/AGENTS.md".source = ./AGENTS.md;
  home.file.".config/opencode/agents".source = ./agent;
  home.file.".config/opencode/commands".source = ./command;
  home.file.".config/opencode/skills".source = ../copilot-cli/skills;
}
