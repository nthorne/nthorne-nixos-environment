{pkgs, ...}: {
  imports = [
    ./auto-session.nix
    ./avante.nix
    ./cmp.nix
    ./codecompanion.nix
    ./conform.nix
    ./copilot.nix
    ./dap.nix
    ./harpoon.nix
    ./indent-blankline.nix
    ./lsp.nix
    ./luasnip.nix
    ./multicursors.nix
    ./oil.nix
    ./refactoring.nix
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

      lualine.enable = true;

      rainbow-delimiters.enable = true;

      render-markdown.enable = true;

      repeat.enable = true;

      rustaceanvim.enable = true;

      undotree.enable = true;

      vim-surround.enable = true;

      which-key.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; [
      vim-tmux-navigator
    ];
  };
}
