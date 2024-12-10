{...}: {
  programs.nixvim = {
    plugins.oil.enable = true;

    keymaps = [
      {
        mode = "n";
        key = "-";
        action = "<cmd>Oil<CR>";
      }
    ];
  };
}
