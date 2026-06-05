{
  pkgs,
  ...
} @ args:
{
  imports = [
    #(import ../workstation.nix args)
    (import ../../packages/copilot-cli args)
  ];

  home.packages =
    with pkgs;
    [
      lnav
    ];
}
