{
  pkgs,
  lib,
  ...
}: let
  # We filter out this file and anything that is not a nix file
  modulesFilter =
    lib.filterAttrs (name: value:
      value == "regular" && name != "default.nix" && (lib.strings.hasSuffix ".nix" name));

  # Apply the filter to all files in the current directory
  nixModules = builtins.attrNames (modulesFilter (builtins.readDir ./.));
in {
  # Convert all paths to absolute paths and import the modules
  imports = builtins.map (path: ./. + "/${path}") nixModules;

  # https://dotfyle.com/
  programs.nixvim = {
    plugins = {
      nvim-bqf.enable = true;

      cmake-tools.enable = true;

      comment.enable = true;

      diffview.enable = true;

      direnv.enable = true;

      fidget.enable = true;

      fugitive.enable = true;

      lualine.enable = true;

      noice.enable = true;

      rainbow-delimiters.enable = true;

      render-markdown.enable = true;

      repeat.enable = true;

      rustaceanvim.enable = true;

      undotree.enable = true;

      vim-surround.enable = true;

      which-key.enable = true;
    };

    extraPlugins = with pkgs.vimPlugins; [
      vim-tmux-navigator
    ];
  };
}
