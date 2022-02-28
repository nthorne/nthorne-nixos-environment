# This derivation should contain configurations that are common
# to all profiles.
args@{ pkgs, lib, ... }:
let
  # pull pkgs and unstable from niv
  sources = import ./nix/sources.nix;
  stable = import sources.nixpkgs {config.allowUnfree = true;};
  unstable = import sources.unstable {config.allowUnfree = true;};

  # NOTE: Will only work on Linux systems 🤷
  hostname = lib.strings.removeSuffix "\n" (builtins.readFile /etc/hostname);

  hostCollection = path: (path + ("/" + hostname));
  hostDotfiles = (hostCollection ./dotfiles);
  hostPackages = (hostCollection ./packages);
  hostScripts =  (hostCollection ./scripts);
in
{
  imports = [
    ./dotfiles/zsh.nix

    # Automatically include <hostname>.nix for host specific configurations,
    # supplying the niv stable and unstable sources as arguments
    (
      import (./. + ("/" + hostname + ".nix")) (args // {stable = stable; unstable = unstable;})
    )

    # .. and as a convenience, automatically pull in e.g. dotfiles/<hostname>/default.nix
    #    here to keep the host specific config files short
  ] ++ (if builtins.pathExists hostDotfiles then [ hostDotfiles ] else [])
    ++ (if builtins.pathExists hostPackages then [ hostPackages ] else [])
    ++ (if builtins.pathExists hostScripts then [ hostScripts ] else []);

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "nthorne";
  home.homeDirectory = "/home/nthorne";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "21.11";

  home.packages = with stable; [
    ag
    conky
    evince
    fasd
    fd
    file
    gparted
    htop
    hyperfine
    irssi
    mosh
    niv
    nvd
    pavucontrol
    qalculate-gtk
    ranger
    shellcheck
    tldr
    tmux
    todoist
    tree
    xsel
    yank

    unstable.firefox
    unstable.neovim

    # evaluation
    autorandr
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
