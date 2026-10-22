args:
{
  imports = [
    ./gitconfig.nix
    ./lnav.nix
    (import ./gh-cli args)
  ];

  home.file.".tmuxinator".source = ./.tmuxinator;
}
