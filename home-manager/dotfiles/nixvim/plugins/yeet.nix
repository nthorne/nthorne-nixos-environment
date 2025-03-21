{pkgs, ...}: {
  programs.nixvim = {
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        name = "yeet-nvim";
        src = pkgs.fetchFromGitHub {
          owner = "samharju";
          repo = "yeet.nvim";
          rev = "v1.0.0"; # Replace with the latest version or commit hash
          sha256 = "sha256-YmyVu/JEkaMTYaPGjNSU5lS84VQCFIpmT5xXUZlg+N4="; # Replace with the correct SHA256 hash
        };
      })
    ];
    keymaps = [
      {
        mode = "n";
        key = "<leader>yt";
        action = "<cmd>lua require('yeet').select_target()<CR>";
        options.desc = "Select Yeet [T]arget";
      }
      {
        mode = "n";
        key = "<leader>ye";
        action = "<cmd>lua require('yeet').execute()<CR>";
        options.desc = "[E]xecute Yeet";
      }
      {
        mode = "n";
        key = "<leader>yc";
        action = "<cmd>lua require('yeet').set_cmd()<CR>";
        options.desc = "Set Yeet [C]ommand";
      }
    ];
  };
}
