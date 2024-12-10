{...}: {
  programs.ripgrep.enable = true;

  programs.nixvim = {
    plugins.telescope.enable = true;
    plugins.web-devicons.enable = true;

    keymaps = [
      {
        mode = "n";
        key = "<leader>sh";
        action = "<cmd>Telescope help_tags<CR>";
      }
      {
        mode = "n";
        key = "<leader>s.";
        action = "<cmd>Telescope oldfiles<CR>";
      }
      {
        mode = "n";
        key = "<leader>sr";
        action = "<cmd>Telescope resume<CR>";
      }
      {
        mode = "n";
        key = "<leader>sd";
        action = "<cmd>Telescope diagnostics<CR>";
      }
      {
        mode = "n";
        key = "<leader>sg";
        action = "<cmd>Telescope live_grep<CR>";
      }
      {
        mode = "n";
        key = "<leader>sw";
        action = "<cmd>Telescope grep_string<CR>";
        options.desc = "[S]earch current [W]ord";
      }
      {
        mode = "n";
        key = "<leader>ss";
        action = "<cmd>Telescope builtin<CR>";
        options.desc = "[S]earch [S]elect Telescope";
      }
      {
        mode = "n";
        key = "<leader>sf";
        action = "<cmd>Telescope find_files<CR>";
      }
      {
        mode = "n";
        key = "<leader>sk";
        action = "<cmd>Telescope keymaps<CR>";
      }
      {
        mode = "n";
        key = "<leader>s/";
        action = "<cmd>Telescope current_buffer_fuzzy_find<CR>";
        options.desc = "[/] Fuzzily search in current buffer";
      }
      {
        mode = "n";
        key = "<leader>sb";
        action = "<cmd>Telescope buffers<CR>";
      }
    ];
  };
}
