{...}: {
  programs.nixvim = {
    plugins = {
      treesitter = {
        enable = true;
        folding.enable = true;
        settings = {
          highlight = {
            enable = true;
          };
          indent = {
            enable = true;
          };

          incremental_selection = {
            enable = true;
            keymaps = {
              init_selection = "<C-space>";
              node_incremental = "<C-space>";
              scope_incremental = false;
              node_decremental = "<bs>";
            };
          };
        };
      };

      treesitter-context.enable = true;

      treesitter-textobjects = {
        enable = true;
        settings.__raw = ''
        {
          select = {
            enable = true,
            lookahead = true,
            keymaps = {
              ["af"] = "@function.outer",
              ["if"] = "@function.inner",
              ["ac"] = "@conditional.outer",
              ["ic"] = "@conditional.inner",
              ["al"] = "@loop.outer",
              ["il"] = "@loop.inner",
            },
          },
          move = {
            enable = true,
            goto_next_start = {
              ["]f"] = "@function.outer",
              ["]c"] = "@conditional.outer",
              ["]l"] = "@loop.outer",
              ["]b"] = "@block.outer",
            },
            goto_previous_start = {
              ["[f"] = "@function.outer",
              ["[c"] = "@conditional.outer",
              ["[l"] = "@loop.outer",
              ["[b"] = "@block.outer",
            },
            goto_next_end = {
              ["]F"] = "@function.outer",
              ["]C"] = "@conditional.outer",
              ["]L"] = "@loop.outer",
              ["]B"] = "@block.outer",
            },
            goto_previous_end = {
              ["[F"] = "@function.outer",
              ["[C"] = "@conditional.outer",
              ["[L"] = "@loop.outer",
              ["[B"] = "@block.outer",
            },
          },
        }'';
      };

      which-key.settings.spec = [
        { __unkeyed = "af"; mode = [ "o" "x" ]; desc = "Around function"; }
        { __unkeyed = "if"; mode = [ "o" "x" ]; desc = "Inside function"; }
        { __unkeyed = "ac"; mode = [ "o" "x" ]; desc = "Around conditional"; }
        { __unkeyed = "ic"; mode = [ "o" "x" ]; desc = "Inside conditional"; }
        { __unkeyed = "al"; mode = [ "o" "x" ]; desc = "Around loop"; }
        { __unkeyed = "il"; mode = [ "o" "x" ]; desc = "Inside loop"; }

        { __unkeyed = "]f"; mode = "n"; desc = "Next function start"; }
        { __unkeyed = "[f"; mode = "n"; desc = "Prev function start"; }
        { __unkeyed = "]F"; mode = "n"; desc = "Next function end"; }
        { __unkeyed = "[F"; mode = "n"; desc = "Prev function end"; }

        { __unkeyed = "]c"; mode = "n"; desc = "Next conditional start"; }
        { __unkeyed = "[c"; mode = "n"; desc = "Prev conditional start"; }
        { __unkeyed = "]C"; mode = "n"; desc = "Next conditional end"; }
        { __unkeyed = "[C"; mode = "n"; desc = "Prev conditional end"; }

        { __unkeyed = "]l"; mode = "n"; desc = "Next loop start"; }
        { __unkeyed = "[l"; mode = "n"; desc = "Prev loop start"; }
        { __unkeyed = "]L"; mode = "n"; desc = "Next loop end"; }
        { __unkeyed = "[L"; mode = "n"; desc = "Prev loop end"; }

        { __unkeyed = "]b"; mode = "n"; desc = "Next block start"; }
        { __unkeyed = "[b"; mode = "n"; desc = "Prev block start"; }
        { __unkeyed = "]B"; mode = "n"; desc = "Next block end"; }
        { __unkeyed = "[B"; mode = "n"; desc = "Prev block end"; }
      ];
    };
  };
}
