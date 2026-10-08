{ ... }: {
  programs.nixvim = {
    globals.mapleader = ",";
    keymaps = [
      {
        mode = "n";
        key = "<leader>o";
        action = "<cmd>only<CR>";
      }
      {
        mode = "n";
        key = "<F2>";
        action = "<cmd>cw<CR>";
      }
      {
        mode = "n";
        key = "<F3>";
        action = "<cmd>Git<CR>";
      }
      {
        mode = "n";
        key = "<F4>";
        action = "<cmd>CMakeBuild<CR>";
      }
      {
        mode = "n";
        key = "<F5>";
        action = "<cmd>CMakeRunTest<CR>";
      }
      {
        mode = "n";
        key = "<F6>";
        action = "<cmd>prev<CR>";
      }
      {
        mode = "n";
        key = "<F7>";
        action = "<cmd>next<CR>";
      }
      {
        mode = "n";
        key = "ä";
        action = "<C-]>";
      }
      {
        mode = "n";
        key = "ö";
        action = ":";
      }
      {
        mode = "n";
        key = "<leader>lcd";
        action = "<cmd>lcd %:p:h<CR>";
      }
      {
        mode = "n";
        key = "<leader>tn";
        action = "<cmd>tabnew<CR>";
      }
      {
        mode = "n";
        key = "<leader>to";
        action = "<cmd>tabonly<CR>";
      }
      {
        mode = "n";
        key = "<leader>tc";
        action = "<cmd>tabclose<CR>";
      }
      {
        mode = "n";
        key = "<leader>p";
        action = "<cmd>let @+ = expand('%:p')<CR>";
        options.desc = "Copy fully qualified file path to clipboard";
      }
      {
        mode = "n";
        key = "<leader>z";
        action = "<cmd>lua require('mini.misc').zoom()<CR>";
        options.desc = "Toggle buffer [Z]oom";
      }
    ];

    # Some convenience mappings to close floating windows/clear search highlights
    # with a single <Esc> press.
    extraConfigLua = ''
      vim.keymap.set("n", "<Esc>", function()
        local closed_float = false

        for _, win in ipairs(vim.api.nvim_list_wins()) do
          if vim.api.nvim_win_is_valid(win) == true then
            local cfg = vim.api.nvim_win_get_config(win)
            if cfg.relative ~= "" then
              vim.api.nvim_win_close(win, false)
              closed_float = true
            end
          end
        end

        if closed_float then
          return
        end

        if vim.v.hlsearch == 1 then
          vim.cmd("nohlsearch")
          return
        end

        vim.api.nvim_feedkeys(
          vim.api.nvim_replace_termcodes("<Esc>", true, false, true),
          "n",
          false
        )
      end, { desc = "Close floats or clear search" })

      vim.keymap.set("n", "<leader>zn", function()
        local node = vim.treesitter.get_node()
        if node then
          local srow, _, erow, _ = node:range()
          local middle = math.floor((srow + erow) / 2)
          vim.api.nvim_win_set_cursor(0, { middle + 1, 0 })
          vim.cmd("normal! zz")
        end
      end, { desc = "Center treesitter node on screen" })
    '';
  };
}
