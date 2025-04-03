{...}: {
  programs.nixvim = {
    plugins = {
      copilot-vim.enable = true;

      copilot-chat = {
        enable = true;
        settings = {
          model = "claude-3.7-sonnet-thought";
        };
      };
      which-key.settings = {
        spec = [
          {
            __unkeyed = "<leader>c";
            group = "Copilot [C]hat";
            mode = "n";
          }
          {
            __unkeyed = "<leader>c";
            group = "Copilot [C]hat";
            mode = "v";
          }
        ];
      };
    };
    keymaps = [
      {
        mode = "n";
        key = "<leader>ct";
        action = "<cmd>CopilotChatToggle<CR>";
        options.desc = "[T]oggle Copilot Chat";
      }
      {
        mode = "v";
        key = "<leader>ce";
        action = "<cmd>CopilotChatExplain<CR>";
        options.desc = "Copilot [E]xplain";
      }
      {
        mode = "v";
        key = "<leader>cr";
        action = "<cmd>CopilotChatReview<CR>";
        options.desc = "Copilot [R]eview";
      }
      {
        mode = "v";
        key = "<leader>co";
        action = "<cmd>CopilotChatOptimize<CR>";
        options.desc = "Copilot [O]ptimize";
      }
      {
        mode = "n";
        key = "<leader>cu";
        action = "<cmd>CopilotChatTests<CR>";
        options.desc = "Copilot [U]nit tests";
      }
      {
        mode = "n";
        key = "<leader>cf";
        action = "<cmd>CopilotChatFix<CR>";
        options.desc = "Copilot [F]ix";
      }
      {
        mode = "n";
        key = "<leader>cd";
        action = "<cmd>CopilotChatFixDiagnostic<CR>";
        options.desc = "Copilot fix [D]iagnostic";
      }
    ];
  };
}
