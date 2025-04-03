{pkgs, ...}: {
  # EVAL: This one works decently, but its usefulness is more on par with copilot.
  #       Looks to be lively development, tough, so it will probably get better.
  # Docs: https://codecompanion.olimorris.dev/
  programs.nixvim = {
    extraPlugins = [
      (pkgs.vimUtils.buildVimPlugin {
        pname = "codecompanion.nvim";
        version = "2025-03-27";
        src = pkgs.fetchFromGitHub {
          owner = "olimorris";
          repo = "codecompanion.nvim";
          rev = "51fe5a782dbbd5cad8189420cb8d38fd7c245684";
          sha256 = "09vjvbf5rxmj2fax0ddcinbvx6mhjdy58fw9d1nf8ll7x8dj5j2s";
        };
        meta.homepage = "https://github.com/olimorris/codecompanion.nvim/";
        meta.hydraPlatforms = [];
      })
    ];

    extraConfigLua = ''
      require("codecompanion").setup({
        adapters = {
          llama3 = function()
            return require("codecompanion.adapters").extend("ollama", {
              name = "qwen2.5-coder",
              schema = {
                model = {
                  default = "qwen2.5-coder:latest",
                },
                num_ctx = {
                  default = 16384,
                },
                num_predict = {
                  default = -1,
                },
              },
            })
          end,
        },
        strategies = {
	  agent = {
	    adapter = "ollama",
	  },
	  chat = {
	    adapter = "ollama",
	  },
	  inline = {
	    adapter = "ollama",
	  },
        },
      })
    '';

    keymaps = [
      {
        mode = "n";
        key = "<leader>ic";
        action = "<cmd>CodeCompanionChat<CR>";
        options.desc = "Code Companion [C]hat";
      }
      {
        mode = "n";
        key = "<leader>ia";
        action = "<cmd>CodeCompanionActions<CR>";
        options.desc = "Code Companion [A]ctions";
      }
    ];
  };
}
