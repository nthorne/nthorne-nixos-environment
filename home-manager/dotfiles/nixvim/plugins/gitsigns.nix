{...}: {
  programs.nixvim = {
    plugins.gitsigns = {
      enable = true;
    };

    extraConfigLua = ''
      local gitsigns = require("gitsigns")

      gitsigns.setup()

    -- Navigation
    vim.keymap.set('n', ']h', function()
      if vim.wo.diff then
        vim.cmd.normal({']h', bang = true})
      else
        gitsigns.nav_hunk('next')
      end
    end, { desc = "Go to Next Hunk" })

    vim.keymap.set('n', '[h', function()
      if vim.wo.diff then
        vim.cmd.normal({'[h', bang = true})
      else
        gitsigns.nav_hunk('prev')
      end
    end, { desc = "Go to Previous Hunk" })

    -- Actions
    vim.keymap.set('n', '<leader>gs', gitsigns.stage_hunk, { desc = "Stage Hunk" })
    vim.keymap.set('n', '<leader>gr', gitsigns.reset_hunk, { desc = "Reset Hunk" })

    vim.keymap.set('v', '<leader>gs', function()
      gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end, { desc = "Stage Hunk (visual)" })

    vim.keymap.set('v', '<leader>gr', function()
      gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end, { desc = "Reset Hunk (visual)" })

    vim.keymap.set('n', '<leader>gS', gitsigns.stage_buffer, { desc = "Stage Buffer" })
    vim.keymap.set('n', '<leader>gR', gitsigns.reset_buffer, { desc = "Reset Buffer" })
    vim.keymap.set('n', '<leader>gp', gitsigns.preview_hunk, { desc = "Preview Hunk" })
    vim.keymap.set('n', '<leader>gi', gitsigns.preview_hunk_inline, { desc = "Preview Hunk Inline" })

    vim.keymap.set('n', '<leader>gb', function()
      gitsigns.blame_line({ full = true })
    end, { desc = "Blame Line" })

    vim.keymap.set('n', '<leader>gd', gitsigns.diffthis, { desc = "Diff This" })

    vim.keymap.set('n', '<leader>gD', function()
      gitsigns.diffthis('~')
    end, { desc = "Diff This (against HEAD)" })

    vim.keymap.set('n', '<leader>gQ', function() gitsigns.setqflist('all') end, { desc = "Set QF List (all)" })
    vim.keymap.set('n', '<leader>gq', gitsigns.setqflist, { desc = "Set QF List (staged)" })

    -- Toggles
    vim.keymap.set('n', '<leader>gtb', gitsigns.toggle_current_line_blame, { desc = "Toggle Current Line Blame" })
    vim.keymap.set('n', '<leader>gtw', gitsigns.toggle_word_diff, { desc = "Toggle Word Diff" })

    -- Text object
    vim.keymap.set({'o', 'x'}, 'ih', gitsigns.select_hunk, { desc = "Select Hunk" })
    '';
  };
}
