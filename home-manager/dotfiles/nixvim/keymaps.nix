{...}: {
  programs.nixvim = {
    globals.mapleader = ",";
    keymaps = [
      {
        mode = "n";
        key = "<leader>o";
        action = "<cmd>only<CR>";
      }
      {
        mode = "n";
        key = "<F2>";
        action = "<cmd>cw<CR>";
      }
      {
        mode = "n";
        key = "<F3>";
        action = "<cmd>Git<CR>";
      }
      {
        mode = "n";
        key = "<F4>";
        action = "<cmd>CMakeBuild<CR>";
      }
      {
        mode = "n";
        key = "<F5>";
        action = "<cmd>CMakeRunTest<CR>";
      }
      {
        mode = "n";
        key = "<F6>";
        action = "<cmd>prev<CR>";
      }
      {
        mode = "n";
        key = "<F7>";
        action = "<cmd>next<CR>";
      }
      {
        mode = "n";
        key = "ä";
        action = "<C-]>";
      }
      {
        mode = "n";
        key = "ö";
        action = ":";
      }
      {
        mode = "n";
        key = "<leader>lcd";
        action = "<cmd>lcd %:p:h<CR>";
      }
      {
        mode = "n";
        key = "<leader>tn";
        action = "<cmd>tabnew<CR>";
      }
      {
        mode = "n";
        key = "<leader>to";
        action = "<cmd>tabonly<CR>";
      }
      {
        mode = "n";
        key = "<leader>tc";
        action = "<cmd>tabclose<CR>";
      }
      {
        mode = "n";
        key = "<leader>p";
        action = "<cmd>let @+ = expand('%:p')<CR>";
        options.desc = "Copy fully qualified file path to clipboard";
      }
    ];
  };
}
