{...}: {
  programs.nixvim = {
    plugins = {
      marks = {
        enable = true;
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "ml";
        action = "<cmd>MarksListAll<CR>";
        options.desc = "[M]arks [L]ist";
      }
    ];
  };
}
