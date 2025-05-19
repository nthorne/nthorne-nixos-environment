{
  ...
}: let
in {
  # References:
  #   - https://github.com/yetone/avante.nvim/issues/1807
  #   - https://github.com/yetone/avante.nvim/issues/1813
  programs.nixvim = {
    plugins = {
      avante = {
        enable = true;

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
