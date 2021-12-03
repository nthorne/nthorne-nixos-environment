{ pkgs, ... }:
let
  unstable = import <nixos-unstable> {};
in
{
  # This derivation should contain configurations that are common
  # to all profiles.
  home.packages = with pkgs; [
    ag
    evince
    fasd
    fd
    file
    gparted
    htop
    hyperfine
    irssi
    mosh
    nvd
    qalculate-gtk
    ranger
    shellcheck
    tldr
    tmux
    tree
    xsel
    yank

    unstable.firefox
    unstable.neovim
  ];

  # NOTE: If reverting to regular direnv, remember to reinstall ~/.direnrc
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;


  programs.kitty = {
    enable = true;

    extraConfig = ''
      font_family      JetBrains Mono
      bold_font        auto
      italic_font      auto
      bold_italic_font auto
      font_size        12.0

      enable_audio_bell no

      # Solarized Dark
      background #002b36
      foreground #839496
      cursor #708183
      selection_background #073642
      color0 #002731
      color8 #001e26
      color1 #d01b24
      color9 #bd3612
      color2 #728905
      color10 #465a61
      color3 #a57705
      color11 #52676f
      color4 #2075c7
      color12 #708183
      color5 #c61b6e
      color13 #5856b9
      color6 #259185
      color14 #81908f
      color7 #e9e2cb
      color15 #fcf4dc
      selection_foreground #93a1a1
      '';
  };
}
