{...}: {
  programs.nixvim = {
    plugins = {
      flash = {
        enable = true;
        settings.modes.search.enabled = true;
      };
    };
    keymaps = [
      {
        mode = ["n" "x" "o"];
        key = "s";
        action = "<cmd>lua require('flash').jump()<CR>";
      }
      {
        mode = ["n" "x" "o"];
        key = "t";
        action = "<cmd>lua require('flash').treesitter()<CR>";
      }
      {
        mode = ["n" "x" "o"];
        key = "T";
        action = "<cmd>lua require('flash').treesitter_search()<CR>";
      }
      {
        mode = "o";
        key = "r";
        action = "<cmd>lua require('flash').remote()<CR>";
      }
    ];
  };
}
