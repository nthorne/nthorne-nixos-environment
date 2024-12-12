{pkgs, ...}@args: {
  imports = [
    ./conform.nix
    ./cmp.nix
    ./lsp.nix
    (import ./luasnip.nix args)
    ./oil.nix
    ./telescope.nix
  ];

  programs.nixvim = {
    plugins.copilot-chat.enable = true;

    plugins.copilot-vim.enable = true;

    plugins.fidget.enable = true;

    plugins.fugitive.enable = true;

    plugins.lualine.enable = true;

    plugins.multicursors.enable = true;

    plugins.rainbow-delimiters.enable = true;

    plugins.repeat.enable = true;

    plugins.rustaceanvim.enable = true;

    plugins.vim-surround.enable = true;

    plugins.treesitter.enable = true;

    plugins.undotree.enable = true;

    plugins.which-key.enable = true;
  };
}
