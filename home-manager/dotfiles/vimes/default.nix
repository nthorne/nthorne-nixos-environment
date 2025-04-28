{
  imports = [
    ./gitconfig.nix
    ./lnav.nix

    ../rr.nix
  ];

  home.file.".tmuxinator".source = ./.tmuxinator;
}
