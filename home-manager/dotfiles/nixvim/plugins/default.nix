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

  programs.nixvim = {
    plugins = {
      nvim-bqf.enable = true;

      cmake-tools.enable = true;

      comment.enable = true;

      diffview.enable = true;

      direnv.enable = true;

      fidget.enable = true;

      fugitive.enable = true;

      lualine.enable = true;

      rainbow-delimiters.enable = true;

      repeat.enable = true;

      rustaceanvim.enable = true;

      undotree.enable = true;

      vim-surround.enable = true;

      which-key.enable = true;
    };
  };
}
