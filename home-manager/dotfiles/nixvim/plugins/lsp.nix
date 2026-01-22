{...}: {
  programs.nixvim = {
    plugins.lsp = {
      enable = true;
      servers = {
        bashls.enable = true;
        ccls.enable = true;
        clangd = {
          enable = true;
          cmd = [
            "clangd" 
            "--clang-tidy"
            "--background-index"
          ];
          onAttach.function = ''
            -- Disable everything except diagnostics
            client.server_capabilities.completionProvider = false
            client.server_capabilities.hoverProvider = false
            client.server_capabilities.definitionProvider = false
            client.server_capabilities.referencesProvider = false
            client.server_capabilities.documentFormattingProvider = false
            client.server_capabilities.documentRangeFormattingProvider = false
            client.server_capabilities.renameProvider = false
            client.server_capabilities.documentSymbolProvider = false
            client.server_capabilities.workspaceSymbolProvider = false
            client.server_capabilities.signatureHelpProvider = false
            client.server_capabilities.implementationProvider = false
            client.server_capabilities.typeDefinitionProvider = false
            client.server_capabilities.declarationProvider = false

            -- Optional: Disable semantic tokens if you want to keep original highlighting
            client.server_capabilities.semanticTokensProvider = nil
          '';
        };
        copilot.enable = true;
        # I need to install chsharp-ls locally in each repo, since
        # I've got different versions of .NET Core installed in different
        # projects.
        csharp_ls = {
          enable = true;
          # NOTE: Use default package for now, and make sure to have
          #       the correct runtime whereever I need it.
          # package = null;
          # cmd = ["dotnet" "tool" "run" "csharp-ls"];
        };
        hls = {
          enable = true;
          installGhc = true;
        };
        jsonls.enable = true;
        nixd.enable = true;
        pyrefly.enable = true;
        ruff.enable = true;
        yamlls.enable = true;
      };
      keymaps = {
        diagnostic = {
          "gj" = "goto_next";
          "gk" = "goto_prev";
        };
        lspBuf = {
          "gd" = "definition";
          "gD" = "references";
          "gt" = "type_definition";
          "gi" = "implementation";
          "K" = "hover";
          "gn" = "incoming_calls";
          "go" = "outgoing_calls";
        };
      };
    };

    # TODO: Why can't I get this binding to work inside lspBuf?
    keymaps = [
      {
        mode = "n";
        key = "ga";
        action = "<cmd>:lua vim.lsp.buf.code_action({filter=function(a) return a.isPreferred end, apply=true})<CR>";
        options.desc = "[A]pply suggested code action";
      }

      {
        mode = "n";
        key = "<leader>nai"; # Disable AI completion
        action.__raw = ''
          function()
            vim.lsp.stop_client(vim.lsp.get_clients({"name", "copilot"}))
            require("sidekick.nes").disable()
          end
        '';
        options.desc = "[N]o [A][I] completion";
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
