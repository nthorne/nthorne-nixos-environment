{...}: {
  programs.nixvim = {
    plugins = {
      dap.enable = true;
      dap-ui.enable = true;
      dap-virtual-text.enable = true;

      which-key.settings = {
        spec = [
          {
            __unkeyed = "<leader>d";
            group = "[D]ebugging";
            mode = "n";
          }
        ];
      };
    };

    keymaps = [
      {
        mode = "n";
        key = "<leader>db";
        action = "<cmd>DapToggleBreakpoint<CR>";
        options.desc = "Toggle [B]reakpoint";
      }
      {
        mode = "n";
        key = "<leader>dc";
        action = "<cmd>DapContinue<CR>";
        options.desc = "[C]ontinue debug session";
      }
      {
        mode = "n";
        key = "<leader>dt";
        action = "<cmd>DapTerminate<CR>";
        options.desc = "[T]erminate debug session";
      }
      {
        mode = "n";
        key = "<leader>do";
        action = "<cmd>DapStepOver<CR>";
        options.desc = "Step [O]ver";
      }
      {
        mode = "n";
        key = "<leader>di";
        action = "<cmd>DapStepInto<CR>";
        options.desc = "Step [I]nto";
      }
      {
        mode = "n";
        key = "<leader>du";
        action = "<cmd>DapStepOut<CR>";
        options.desc = "Step o[U]t";
      }
      {
        mode = "n";
        key = "<leader>de";
        action = "<cmd>lua require('dapui').eval()<CR>";
        options.desc = "[E]valuate expression";
      }
      {
        mode = "n";
        key = "<leader>dC";
        action = "<cmd>lua require('dap').run_to_cursor()<CR>";
        options.desc = "Run to [C]ursor";
      }
    ];

    extraConfigLua = ''
      local dap = require("dap")
      require("nvim-dap-virtual-text").setup()

      dap.adapters.gdb = {
        type = "executable",
        command = "gdb",
        args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
      }

      dap.configurations.cpp = {
        {
          name = "Launch",
          type = "gdb",
          request = "launch",
          program = function()
            return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = "$${workspaceFolder}",
          stopAtBeginningOfMainSubprogram = false,
        },
        {
          name = "Select and attach to process",
          type = "gdb",
          request = "attach",
          program = function()
             return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          pid = function()
             local name = vim.fn.input('Executable name (filter): ')
             return require("dap.utils").pick_process({ filter = name })
          end,
          cwd = '$${workspaceFolder}'
        },
        {
          name = 'Attach to gdbserver :1234',
          type = 'gdb',
          request = 'attach',
          target = 'localhost:1234',
          program = function()
             return vim.fn.input('Path to executable: ', vim.fn.getcwd() .. '/', 'file')
          end,
          cwd = '$${workspaceFolder}'
        },
      }

      local dapui = require("dapui")
      dapui.setup()

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    '';
  };
}
