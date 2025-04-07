{...}: {
  imports = [
    ./auto-session.nix
    ./avante.nix
    ./cmp.nix
    ./codecompanion.nix
    ./conform.nix
    ./copilot.nix
    ./dap.nix
    ./lsp.nix
    ./luasnip.nix
    ./multicursors.nix
    ./oil.nix
    ./telescope.nix
    ./treesitter.nix
    ./yeet.nix
  ];

  # https://dotfyle.com/
  programs.nixvim = {
    plugins = {
      nvim-bqf.enable = true;

      cmake-tools.enable = true;

      comment.enable = true;

      diffview.enable = true;

      direnv.enable = true;

      fidget.enable = true;

      fugitive.enable = true;

      harpoon = {
        enable = true;
        enableTelescope = true;
      };

      lualine.enable = true;

      rainbow-delimiters.enable = true;

      render-markdown.enable = true;

      repeat.enable = true;

      rustaceanvim.enable = true;

      undotree.enable = true;

      vim-surround.enable = true;

      which-key.enable = true;
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>hm";
        action = "<cmd>lua require('harpoon.mark').add_file()<CR>";
        options.desc = "Harpoon [M]ark";
      }
      {
        mode = "n";
        key = "<leader>hq";
        action = "<cmd>lua require('harpoon.ui').toggle_quick_menu()<CR>";
        options.desc = "Harpoon [M]ark";
      }
    ];
  };
}
