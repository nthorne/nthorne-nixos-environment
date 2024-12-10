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

    # TODO: Why can't I get this binding to work inside lspBuf?
    keymaps = [
      {
        mode = "n";
        key = "<leader>a";
        action = "<cmd>:lua vim.lsp.buf.code_action({filter=function(a) return a.isPreferred end, apply=true})<CR>";
        options.desc = "[A]pply suggested code action";
      }
    ];

    plugins.lsp-format = {
      enable = true;
    };
  };
}
