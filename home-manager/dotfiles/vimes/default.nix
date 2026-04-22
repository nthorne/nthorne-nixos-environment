{
  imports = [
    ./gitconfig.nix
    ./lnav.nix
  ];

  home.file.".tmuxinator".source = ./.tmuxinator;
}
