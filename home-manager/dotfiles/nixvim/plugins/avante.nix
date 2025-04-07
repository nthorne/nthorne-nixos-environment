{...}: {
  # EVAL: This one works decently, but its usefulness is more on par with copilot.
  #       Looks to be lively development, tough, so it will probably get better.  programs.nixvim = {
  programs.nixvim = {
    plugins = {
      avante = {
        enable = true;

        settings = {
          provider = "ollama";
          vendors = {
            ollama = {
              __inherited_from = "openai";
              api_key_name = "";
              endpoint = "http://127.0.0.1:11434/v1";
              model = "qwen2.5-coder:latest";
              stream = true;
            };
          };
          # Recommended for ollama
          behaviour = {
            enable_cursor_planning_mode = true;
          };
        };
      };
    };
  };
}
