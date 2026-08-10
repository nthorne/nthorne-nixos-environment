{pkgs, ...}:
{ 
  programs.nixvim = {
    # We pull this one in from nixpkgs, so that we do not add any other
    # dependencies than what we already have.
    extraPlugins = [ pkgs.vimPlugins.sidekick-nvim ];
    extraConfigLua = ''
        -- setup sidekick
        require("sidekick").setup({
          -- add any settings here
        })
        '';
    keymaps = [
      {
        mode = "n";
        key = "<tab>";
        action.__raw = ''
            function()
              -- if there is a next edit, jump to it, otherwise apply it if any
              if not require("sidekick").nes_jump_or_apply() then
                return "<Tab>" -- fallback to normal tab
              end
            end
            '';
        options.desc = "Goto/Apply Next Edit Suggestion";
      }
      {
        mode = "n";
        key = "<leader>cct";
        action.__raw = ''function() require("sidekick.cli").toggle({ name = "copilot", focus = true }) end'';
        options.desc = "[C]opilot [C]LI [T]oggle";
      }
      {
        mode = "n";
        key = "<leader>ccs";
        action.__raw = ''function() require("sidekick.cli").select({filter = {installed = true}}) end'';
        options.desc = "[C]opilot [C]LI [S]elect";
      }
      {
        mode = "n";
        key = "<leader>ccc";
        action.__raw = ''function() require("sidekick.cli").close() end'';
        options.desc = "[C]opilot [C]LI [C]close ";
      }
      {
        mode = ["x" "n"];
        key = "<leader>ccst";
        action.__raw = ''function() require("sidekick.cli").send({ msg = "{this}" }) end'';
        options.desc = "[C]opilot [C]LI [S]end [T]his";
      }
      {
        mode = "n";
        key = "<leader>ccsf";
        action.__raw = ''function() require("sidekick.cli").send({ msg = "{file}" }) end'';
        options.desc = "[C]opilot [C]LI [S]end [F]ile";
      }
      {
        mode = "x";
        key = "<leader>ccsv";
        action.__raw = ''function() require("sidekick.cli").send({ msg = "{selection}" }) end'';
        options.desc = "[C]opilot [C]LI [S]end [V]isual Selection";
      }
      {
        mode = ["x" "n"];
        key = "<leader>ccp";
        action.__raw = ''function() require("sidekick.cli").prompt() end'';
        options.desc = "[C]opilot [C]LI Select [P]rompt";
      }
    ];
  };
}
