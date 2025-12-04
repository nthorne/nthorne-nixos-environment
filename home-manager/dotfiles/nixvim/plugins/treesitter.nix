{...}: {
  programs.nixvim = {
    plugins = {
      treesitter = {
        enable = true;
        folding = true;
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
    };
  };
}
