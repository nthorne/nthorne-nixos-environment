{...}: {
  programs.nixvim = {
    plugins = {
      trouble = {
        enable = true;
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>ul";
        action = "<cmd>Trouble lsp toggle focus=false win.position=right<cr>";
        options.desc = "Show [L]SP info";
      }
      {
        mode = "n";
        key = "<leader>ud";
        action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>";
        options.desc = "Buffer [D]iagnostics";
      }
    ];
    plugins.which-key.settings = {
      spec = [
        {
          __unkeyed = "<leader>u";
          group = "Tro[U]ble";
          mode = ["n"];
        }
      ];
    };
  };
}
