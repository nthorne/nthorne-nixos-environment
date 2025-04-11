{...}: {
  programs.nixvim = {
    plugins = {
      refactoring = {
        enable = true;
        settings = {
          prompt_func_return_type = {
            cpp = true;
          };
          prompt_func_param_type = {
            cpp = true;
          };
        };
      };
    };

    extraConfigLua = ''
      vim.keymap.set({ "n", "x" }, "<leader>re", function()
        return require('refactoring').refactor('Extract Function')
      end, { expr = true, desc = "[E]xtract Function" })

      vim.keymap.set({ "n", "x" }, "<leader>rf", function()
        return require('refactoring').refactor('Extract Function To File')
      end, { expr = true , desc = "Function to [F]ile" })

      vim.keymap.set({ "n", "x" }, "<leader>rv", function()
        return require('refactoring').refactor('Extract Variable')
      end, { expr = true, desc = "Extract [V]ariable" })

      vim.keymap.set({ "n", "x" }, "<leader>rI", function()
        return require('refactoring').refactor('Inline Function')
      end, { expr = true, desc = "[I]nline Function" })

      vim.keymap.set({ "n", "x" }, "<leader>ri", function()
        return require('refactoring').refactor('Inline Variable')
      end, { expr = true , desc = "[i]nline Variable" })

      vim.keymap.set({ "n", "x" }, "<leader>rbb", function()
        return require('refactoring').refactor('Extract Block')
      end, { expr = true, desc = "[B]lock to [B]uffer" })

      vim.keymap.set({ "n", "x" }, "<leader>rbf", function()
        return require('refactoring').refactor('Extract Block To File')
      end, { expr = true, desc = "[B]lock to [F]ile" })
    '';

    plugins.which-key.settings = {
      spec = [
        {
          __unkeyed = "<leader>r";
          group = "[R]efactor";
          mode = ["n" "x"];
        }
      ];
    };
  };
}
