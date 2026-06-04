{
  lib,
  pkgs,
  ...
}: {
  programs.nixvim = {
    plugins.conform-nvim = {
      enable = true;
      settings = {
        # never: never use the LSP for formatting.
        # fallback: LSP formatting is used when no other formatters are available.
        # prefer: Use only LSP formatting when available.
        # first: LSP formatting is used when available and then other formatters.
        # last: Other formatters are used then LSP formatting when available.
        # format_on_save = "function() return end";
        default_format_opts.lsp_format = "fallback";
        formatters_by_ft = {
          cpp = ["clang_format"];
          nix = ["alejandra"];
          yaml = ["yamlfmt"];
          python = ["isort" "black"];
        };

        formatters = {
          alejandra = {
            command = lib.getExe pkgs.alejandra;
          };
          black = {
            command = lib.getExe pkgs.black;
          };
          yamlfmt = {
            command = lib.getExe pkgs.yamlfmt;
          };
        };
      };
    };

    keymaps = [
      {
        mode = "";
        key = "<leader>f";
        action.__raw = ''
          function()
            require('conform').format { async = true, lsp_fallback = true }
          end
        '';
        options = {
          desc = "[F]ormat buffer";
        };
      }
    ];
  };
}
