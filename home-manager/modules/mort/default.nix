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
        xlsx2csv
      ];

    nixvim = {
      # We use GitHub Enterprise for Copilot Vim plugins ..
      useGHE = true;
      gheURL = "https://logisnext.ghe.com/";
    };
  };
}
