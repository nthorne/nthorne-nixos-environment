{ config, lib, ... }: {
  options.nixvim.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
    description = ''
      Whether to install the nixvim configuration. Hosts where the editor is
      not the main tool can disable this and get plain vim instead: the
      nixvim closure is roughly 14 GiB.
    '';
  };

  config.programs.vim = lib.mkIf (!config.nixvim.enable) {
    enable = true;
    defaultEditor = true;
  };
}
