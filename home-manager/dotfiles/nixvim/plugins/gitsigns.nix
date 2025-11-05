{...}: {
  programs.nixvim = {
    plugins.gitsigns = {
      enable = true;
    };

    extraConfigLua = ''
      local gitsigns = require("gitsigns")

      gitsigns.setup()

    -- Navigation
    vim.keymap.set('n', ']c', function()
      if vim.wo.diff then
        vim.cmd.normal({']c', bang = true})
      else
        gitsigns.nav_hunk('next')
      end
    end)

    vim.keymap.set('n', '[c', function()
      if vim.wo.diff then
        vim.cmd.normal({'[c', bang = true})
      else
        gitsigns.nav_hunk('prev')
      end
    end)

    -- Actions
    vim.keymap.set('n', '<leader>ghs', gitsigns.stage_hunk, { desc = "Stage Hunk" })
    vim.keymap.set('n', '<leader>ghr', gitsigns.reset_hunk, { desc = "Reset Hunk" })

    vim.keymap.set('v', '<leader>ghs', function()
      gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end, { desc = "Stage Hunk (visual)" })

    vim.keymap.set('v', '<leader>ghr', function()
      gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
    end, { desc = "Reset Hunk (visual)" })

    vim.keymap.set('n', '<leader>ghS', gitsigns.stage_buffer, { desc = "Stage Buffer" })
    vim.keymap.set('n', '<leader>ghR', gitsigns.reset_buffer, { desc = "Reset Buffer" })
    vim.keymap.set('n', '<leader>ghp', gitsigns.preview_hunk, { desc = "Preview Hunk" })
    vim.keymap.set('n', '<leader>ghi', gitsigns.preview_hunk_inline, { desc = "Preview Hunk Inline" })

    vim.keymap.set('n', '<leader>ghb', function()
      gitsigns.blame_line({ full = true })
    end, { desc = "Blame Line" })

    vim.keymap.set('n', '<leader>ghd', gitsigns.diffthis, { desc = "Diff This" })

    vim.keymap.set('n', '<leader>ghD', function()
      gitsigns.diffthis('~')
    end, { desc = "Diff This (against HEAD)" })

    vim.keymap.set('n', '<leader>ghQ', function() gitsigns.setqflist('all') end, { desc = "Set QF List (all)" })
    vim.keymap.set('n', '<leader>ghq', gitsigns.setqflist, { desc = "Set QF List (staged)" })

    -- Toggles
    vim.keymap.set('n', '<leader>gtb', gitsigns.toggle_current_line_blame, { desc = "Toggle Current Line Blame" })
    vim.keymap.set('n', '<leader>gtw', gitsigns.toggle_word_diff, { desc = "Toggle Word Diff" })

    -- Text object
    vim.keymap.set({'o', 'x'}, 'ih', gitsigns.select_hunk, { desc = "Select Hunk" })
    '';
  };
}
