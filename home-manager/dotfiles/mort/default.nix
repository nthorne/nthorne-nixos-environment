{ pkgs, ... }:
{
  imports = [
    ./gitconfig.nix
  ];

  programs.nixvim.plugins.lsp.servers.groovyls = {
          enable = true;
          package = pkgs.groovy-language-server;
  };
}
