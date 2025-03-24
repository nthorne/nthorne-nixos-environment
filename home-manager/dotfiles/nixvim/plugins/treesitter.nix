{...}: {
  programs.nixvim = {
    plugins = {
      treesitter = {
        enable = true;
        folding = true;
        settings = {
          highlight = {
            enable = true;
          };
          indent = {
            enable = true;
          };
        };
      };
      treesitter-context.enable = true;
    };
  };
}
