{pkgs, ...}: let
  avanteMain = pkgs.vimPlugins.avante-nvim.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "yetone";
      repo = "avante.nvim";
      rev = "87ea15bb94f0707a5fd154f11f5ed419c17392d1";
      sha256 = "sha256-zZzLDfxAe7SAwVqDoTAO9SFc0OdS0wctzoN+E/qZu8E=";
    };
    version = "2025-04-09";
    # Require setup so we skip these.
    nvimSkipModules = [
      "avante.providers.vertex_claude"
      "avante.providers.azure"
      "avante.providers.ollama"
      "avante.providers.copilot"
    ];

    dependencies = with pkgs.vimPlugins; [
      copilot-lua
      dressing-nvim
      fzf-lua
      img-clip-nvim
      mini-pick
      nui-nvim
      nvim-cmp
      nvim-treesitter
      nvim-web-devicons
      plenary-nvim
      telescope-nvim
    ];
  });
in {
  # References:
  #   - https://github.com/yetone/avante.nvim/issues/1807
  #   - https://github.com/yetone/avante.nvim/issues/1813
  programs.nixvim = {
    plugins = {
      avante = {
        enable = true;

        package = avanteMain;

        settings = {
          provider = "copilot";
          copilot = {
            model = "claude-3.7-sonnet";
          };
          copilotthink = {
            __inherited_from = "copilot";
            model = "claude-3.7-sonnet-thought";
            timeout = 600000;
            max_completion_tokens = 64000;
          };
          ollama = {
            model = "qwen2.5-coder:latest";
          };
          # Recommended for ollama
          behaviour = {
            enable_cursor_planning_mode = false;
          };
        };
      };
    };
  };
}
