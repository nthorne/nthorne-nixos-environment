{...}: {
  programs.ripgrep.enable = true;

  programs.nixvim = {
    plugins.web-devicons.enable = true;

    plugins = {
      telescope = {
        enable = true;

        extensions.fzf-native.enable = true;

        keymaps = {
          "<leader>sh" = {
            action = "help_tags";
          };
          "<leader>s." = {
            action = "oldfiles";
          };
          "<leader>su" = {
            action = "resume";
          };
          "<leader>sd" = {
            action = "diagnostics";
          };
          "<leader>sg" = {
            action = "live_grep";
          };
          "<leader>sw" = {
            action = "grep_string";
            options.desc = "[S]earch current [W]ord";
          };
          "<leader>ss" = {
            action = "builtin";
            options.desc = "[S]earch [S]elect Telescope";
          };
          "<leader>sf" = {
            action = "find_files";
          };
          "<leader>sk" = {
            action = "keymaps";
          };
          "<leader>s/" = {
            action = "current_buffer_fuzzy_find";
            options.desc = "[/] Fuzzily search in current buffer";
          };
          "<leader>sb" = {
            action = "buffers";
          };
          "<leader>sc" = {
            action = "commands";
          };
          "<leader>sy" = {
            action = "lsp_document_symbols";
          };
          "<leader>sr" = {
            action = "registers";
          };
          "<leader>sm" = {
            action = "marks";
          };
        };
        luaConfig.post = ''
          local actions = require("telescope.actions")
          local open_with_trouble = require("trouble.sources.telescope").open
          local telescope = require("telescope")

          telescope.setup({
            defaults = {
              mappings = {
                i = { ["<c-u>"] = open_with_trouble },
                n = { ["<c-u>"] = open_with_trouble },
              },
            },
          })
        '';
      };
      which-key.settings = {
        spec = [
          {
            __unkeyed = "<leader>s";
            group = "Tele[S]cope";
            mode = "n";
          }
        ];
      };
    };
  };
}
