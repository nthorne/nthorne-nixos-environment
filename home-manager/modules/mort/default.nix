{
  pkgs,
  ...
} @ args:
{
  imports = [
    #(import ../workstation.nix args)
  ];

  home.packages =
    with pkgs;
    [
      lnav
    ];
}
