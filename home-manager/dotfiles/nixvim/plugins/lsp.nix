{...}: {
  programs.nixvim = {
    plugins.lsp = {
      enable = true;
      servers = {
        bashls.enable = true;
        clangd.enable = true;
        # I need to install chsharp-ls locally in each repo, since
        # I've got different versions of .NET Core installed in different
        # projects.
        csharp_ls = {
          enable = true;
          package = null;
          cmd = ["dotnet" "tool" "run" "csharp-ls"];
        };
        hls = {
          enable = true;
          installGhc = true;
        };
        nixd.enable = true;
        pylsp.enable = true;
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
          "gr" = "rename";
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

    # Add descriptions to lsp keymaps
    plugins.which-key.settings.spec = [
      {
        __unkeyed = "<leader>j";
        mode = "n";
        desc = "Go to next diagnostic";
      }
      {
        __unkeyed = "<leader>k";
        mode = "n";
        desc = "Go to prev diagnostic";
      }
      {
        __unkeyed = "gd";
        mode = "n";
        desc = "Go to [d]efinition";
      }
      {
        __unkeyed = "gD";
        mode = "n";
        desc = "Go to references";
      }
      {
        __unkeyed = "gt";
        mode = "n";
        desc = "Go to type definition";
      }
      {
        __unkeyed = "gi";
        mode = "n";
        desc = "Go to implementation";
      }
      {
        __unkeyed = "gr";
        mode = "n";
        desc = "Rename";
      }
      {
        __unkeyed = "K";
        mode = "n";
        desc = "Hover";
      }
    ];
  };
}
