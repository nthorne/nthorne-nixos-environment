{
  lib,
  flake-inputs,
  ...
}: let
  system = flake-inputs.system;
  mcphub-nvim = flake-inputs.mcphub-nvim.packages."${system}".default;
  mcp-hub = flake-inputs.mcp-hub.packages."${system}".default;
in {
  programs.nixvim = {
    extraPlugins = [
      mcphub-nvim
    ];

    # Note: Some config has been added to the Avante module as well..
    extraConfigLua = ''
      require('mcphub').setup({
        cmd = '${lib.getExe' mcp-hub "mcp-hub"}';
        -- cmdArgs = '--port 37373 --config ~/.config/mcphub/servers.json';
      })
    '';
  };
}
