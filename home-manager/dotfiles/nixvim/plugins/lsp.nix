{...}: {
  programs.nixvim = {
    plugins.lsp = {
      enable = true;
      servers = {
        bashls.enable = true;
        clangd.enable = true;
        hls = {
          enable = true;
          installGhc = true;
        };
        nixd.enable = true;
        ruff.enable = true;
      };
      keymaps = {
        diagnostic = {
          "<leader>j" = "goto_next";
          "<leader>k" = "goto_prev";
        };
        lspBuf = {
          "gd" = "definition";
          "gD" = "references";
          "gt" = "type_definition";
          "gi" = "implementation";
          "K" = "hover";
        };
      };
    };

    plugins.lsp-format = {
      enable = true;
    };
  };
}
