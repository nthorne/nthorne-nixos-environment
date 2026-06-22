{ config, lib, ... }: {
  imports = [
    ./keymaps.nix
    ./options.nix
    ./plugins
  ];

  options = {
    nixvim.useGHE = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Whether to use GitHub Enterprise for Copilot Vim plugins";
    };
    nixvim.gheURL = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "The URL of the GitHub Enterprise instance to use for Copilot Vim plugins (if useGHE is true)";
    };
  };

  config = {
    programs.nixvim = {
      enable = true;
      nixpkgs.config.allowUnfree = true;
    };

    assertions = [
      {
        assertion = !config.nixvim.useGHE || config.nixvim.gheURL != "";
        message = "Invalid configuration: If useGHE is true, gheURL must be set to a non-empty string";
      }
    ];
  };
}
