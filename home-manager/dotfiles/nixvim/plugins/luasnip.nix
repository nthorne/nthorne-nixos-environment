{pkgs, ...}: {
  programs.nixvim.plugins.luasnip = {
    enable = true;
    settings = {
      enable_autosnippets = true;
      store_selection_keys = "<tab>";
    };
    fromVscode = [
      {
        lazyLoad = true;
        paths = "${pkgs.vimPlugins.friendly-snippets}";
      }
      {
        lazyLoad = true;
        paths = ./snippets;
      }
    ];
  };
}
