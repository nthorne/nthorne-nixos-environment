{...}: {
  imports = [
    ./cmp.nix
    ./conform.nix
    ./lsp.nix
    ./luasnip.nix
    ./multicursors.nix
    ./oil.nix
    ./telescope.nix
    ./treesitter.nix
  ];

  programs.nixvim = {
    plugins = {
      cmake-tools.enable = true;

      comment.enable = true;

      copilot-chat.enable = true;

      copilot-vim.enable = true;

      diffview.enable = true;

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
