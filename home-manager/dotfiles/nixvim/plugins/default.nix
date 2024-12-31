{pkgs, ...}: {
  imports = [
    ./cmp.nix
    ./conform.nix
    ./lsp.nix
    ./luasnip.nix
    ./oil.nix
    ./telescope.nix
    ./treesitter.nix
  ];

  programs.nixvim = {
    plugins.comment.enable = true;

    plugins.copilot-chat.enable = true;

    plugins.copilot-vim.enable = true;

    plugins.fidget.enable = true;

    plugins.fugitive.enable = true;

    plugins.lualine.enable = true;

    plugins.multicursors.enable = true;

    plugins.rainbow-delimiters.enable = true;

    plugins.repeat.enable = true;

    plugins.rustaceanvim.enable = true;

    plugins.undotree.enable = true;

    plugins.vim-surround.enable = true;

    plugins.which-key.enable = true;
  };
}
