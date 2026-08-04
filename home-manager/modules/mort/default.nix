{
  pkgs,
  ...
} @ args:
{
  imports = [
    (import ../../packages/copilot-cli args)
  ];

  config = {
    home.packages =
      with pkgs;
      [
        entr
        hunk
        lnav
      ];

    nixvim = {
      # We use GitHub Enterprise for Copilot Vim plugins ..
      useGHE = true;
      gheURL = "https://logisnext.ghe.com/";
    };
  };
}
