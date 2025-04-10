{...}: {
  programs.nixvim = {
    plugins = {
      auto-session = {
        enable = true;
        settings = {
          close_unsupported_windows = true;
        };
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>sa";
        action = "<cmd>Telescope session-lens<cr>";
        options.desc = "Search [A]uto-Sessions";
      }
    ];
  };
}
