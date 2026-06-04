{...}: {
  imports = [
    ./keymaps.nix
    ./options.nix
    ./plugins
  ];

  programs.nixvim = {
    enable = true;
    nixpkgs.config.allowUnfree = true;
  };
}
