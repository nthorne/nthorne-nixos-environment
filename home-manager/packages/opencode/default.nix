{
  pkgs,
  flake-inputs,
  ...
}: let
in {
  home.packages = with pkgs; [
    rtk
  ];
  programs.opencode = {
    enable = true;
    settings = {
      share = "disabled";
      autoupdate = false;
      enabled_providers = [ "github-copilot" "ollama" ];
      model = "github-copilot/claude-haiku-4.5";
      plugin = [
        "@mohak34/opencode-notifier@latest"
        "@tarquinen/opencode-dcp@latest"
      ];
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

      permission = {
        # Safe operations - auto-allow
        read = "allow";
        grep = "allow";
        glob = "allow";
        list = "allow";
        edit = "allow";

        # Require approval or block dangerous commands
        bash = {
          "*" = "ask";

          # Hard blocks - never allow
          "sudo *" = "deny";
          "*git push *" = "deny";
          "*git push" = "deny";
          "nixos-rebuild switch *" = "deny";
          "nixos-rebuild switch" = "deny";
          "nixos-rebuild test *" = "deny";
          "nixos-rebuild test" = "deny";
          "just switch *" = "deny";
          "just switch" = "deny";
          "just test *" = "deny";
          "just test" = "deny";
          "rm -rf *" = "deny";

          # Safe git commands - auto-allow (glob in from to catch rtk versions)
          "*git add *" = "allow";
          "*git branch *" = "allow";
          "*git checkout *" = "allow";
          "*git commit *" = "allow";
          "*git diff *" = "allow";
          "*git log *" = "allow";
          "*git status *" = "allow";
          "*git show *" = "allow";
          "*git show" = "allow";

          # Safe github CLI commands - auto-allow (glob in from to catch rtk versions)
          "*gh pr view *" = "allow";
          "*gh pr view" = "allow";
          "*gh issue view *" = "allow";
          "*gh issue view" = "allow";

          # Safe nix commands - auto-allow
          "nix fmt *" = "allow";
          "nix fmt" = "allow";
          "just *" = "allow";

          # Safe generic commands - auto-allow
          "ls *" = "allow";
          "ls" = "allow";
          "cat *" = "allow";
          "cat" = "allow";
          "echo *" = "allow";
          "find *" = "allow";
          "find" = "allow";
          "grep *" = "allow";
          "grep" = "allow";
          "head *" = "allow";
          "head" = "allow";
          "rg *" = "allow";
          "sort" = "allow";
          "wc *" = "allow";
          "wc" = "allow";

          # .. and the same versions running through rtk
          "rtk ls *" = "allow";
          "rtk ls" = "allow";
          "rtk cat *" = "allow";
          "rtk cat" = "allow";
          "rtk grep *" = "allow";
          "rtk grep" = "allow";
          "rtk find *" = "allow";
          "rtk find" = "allow";
          "rtk wc *" = "allow";
          "rtk wc" = "allow";
        };

        external_directory = {
          "*" = "ask";
          "/tmp/*" = "allow";
        };
      };
     };

    tui.keybinds = {
      "session_fork" = "<leader>f";
    };
  };

  home.file.".config/opencode/AGENTS.md".source = ./AGENTS.md;
  home.file.".config/opencode/agents".source = ./agents;
  home.file.".config/opencode/commands".source = ./commands;
  home.file.".config/opencode/plugins".source = ./plugins;
  home.file.".config/opencode/skills".source = ../copilot-cli/skills;
}
