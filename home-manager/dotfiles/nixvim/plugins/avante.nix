{pkgs, ...}: let
  # Wait for 0.0.24 to be released to unstable
  avanteMain = pkgs.vimPlugins.avante-nvim.overrideAttrs (old: {
    src = pkgs.fetchFromGitHub {
      owner = "yetone";
      repo = "avante.nvim";
      rev = "adae032f5fbc611d59545792d3c5bb1c9ddc3fdb";
      sha256 = "sha256-v99yu5LvwdmHBcH61L6JIqjQkZR8Lm2fR/uzQZNPo38=";
    };
    version = "2025-05-10";
    # Require setup so we skip these.
    nvimSkipModules = [
      "avante.providers.azure"
      "avante.providers.copilot"
      "avante.providers.gemini"
      "avante.providers.ollama"
      "avante.providers.vertex_claude"
      "avante.providers.vertex"
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
          vendors = {
            copilotthink = {
              __inherited_from = "copilot";
              model = "claude-3.7-sonnet-thought";
              timeout = 600000;
              max_completion_tokens = 64000;
            };
          };
          ollama = {
            model = "qwen2.5-coder:latest";
          };
          # Recommended for ollama
          #behaviour = {
          #  enable_cursor_planning_mode = false;
          #};

          # Allow for mcphub to update the prompt
          system_prompt.__raw = ''
            function()
              local hub = require("mcphub").get_hub_instance()
              return hub:get_active_servers_prompt()
            end'';
          custom_tools.__raw = ''
            function()
              return {
                require("mcphub.extensions.avante").mcp_tool(),
              }
            end'';
        };
      };
    };
  };
}
