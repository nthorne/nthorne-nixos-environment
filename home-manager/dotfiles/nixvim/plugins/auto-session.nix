{...}: {
  programs.nixvim = {
    plugins = {
      auto-session.enable = true;
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
