{...}: {
  programs.nixvim = {
    plugins.lsp = {
      enable = true;
      servers = {
        bashls.enable = true;
        ccls.enable = true;
        copilot = {
          enable = true;
          settings = {
            github-enterprise = {
              uri = "https://logisnext.ghe.com/";
            };
          };
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
         key = "<leader>nai"; # Toggle AI completion
         action.__raw = ''
           function()
             if vim.g.copilot_enabled == 0 then
               vim.g.copilot_enabled = 1
               vim.notify("Copilot enabled", vim.log.levels.INFO)
             else
               for _, client in ipairs(vim.lsp.get_clients()) do
                 if client.name:lower() == "github copilot" or client.name:lower() == "copilot" then
                   vim.lsp.stop_client(client.id)
                 end
               end
               vim.g.copilot_enabled = 0
               require("sidekick.nes").disable()
               vim.notify("Copilot disabled", vim.log.levels.INFO)
             end
           end
         '';
         options.desc = "Toggle [N]o [A][I] completion";
       }
    ];

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
