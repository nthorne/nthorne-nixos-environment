{ flake-inputs, ... }:
{
  home.file = {
    ".xmonad/xmonad.hs".source = "${flake-inputs.nthorne-xmonad}/xmonad-nixos.hs";
  };
}
