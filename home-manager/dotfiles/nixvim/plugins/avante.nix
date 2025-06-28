{
  ...
}: let
  models = {
    claude = "claude-sonnet-4";
    claudeThought = "claude-3.7-sonnet-thought";
    qwen = "qwen2.5-coder:latest";
  };
in {
  programs.nixvim = {
    plugins = {
      avante = {
        enable = true;

        settings = {
          # Set the default provider to use
          provider = "copilot";

          # Configure all available providers
          providers = {
            # Default Claude provider through Copilot API
            copilot.model = models.claude;
            
            # Extended provider with longer timeouts for complex reasoning
            copilotthink = {
              __inherited_from = "copilot";
              model = models.claudeThought;
              timeout = 600000; # 10 minutes
              max_completion_tokens = 64000;
            };
            
            # Local model option through Ollama
            ollama.model = models.qwen;
          };

          # Ollama-specific settings (disabled by default)
          # Uncomment this section if using Ollama as primary provider
          # behaviour = {
          #   enable_cursor_planning_mode = false;
          # };

          # MCP Integration Settings
          # Allow for mcphub to dynamically update the prompt
          system_prompt.__raw = ''
            function()
              local hub = require("mcphub").get_hub_instance()
              return hub:get_active_servers_prompt()
            end'';
          
          # Add MCP tools to Avante
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
