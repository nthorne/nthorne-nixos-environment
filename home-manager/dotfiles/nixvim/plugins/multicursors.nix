{...}: {
  programs.nixvim = {
    plugins.multicursors = {
      enable = true;
    };

    keymaps = [
      {
        mode = [ "n" "v" ];
        key = "<leader>m";
        action = "<cmd>MCstart<cr>";
        options.desc = "Start [M]ulticursors";
      }
    ];
  };
}
