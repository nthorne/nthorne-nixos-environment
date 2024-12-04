# This derivation should contain configurations that are common
# to all profiles.
args@{
  pkgs,
  flake-inputs,
  ...
}:
let
  hostname = flake-inputs.hostname;

  hostCollection = path: (path + ("/" + hostname));
  hostDotfiles = (hostCollection ./dotfiles);
  hostPackages = (hostCollection ./packages);
  hostScripts = (hostCollection ./scripts);

  system = flake-inputs.system;
  stable = import flake-inputs.nixpkgs {
    config = {
      allowUnfree = true;
    };
    system = "${system}";
  };
  unstable = import flake-inputs.unstable {
    config.allowUnfree = true;
    system = "${system}";
  };
in
{
  imports =
    [
      ./dotfiles/zsh.nix
      ./dotfiles/waybar.nix
      ./dotfiles/kitty.nix
      ./dotfiles/hyprlock.nix
      ./dotfiles/hyprland.nix

      # Automatically include <hostname>.nix for host specific configurations,
      # supplying the niv stable and unstable sources as arguments
      (import (./. + ("/" + hostname + ".nix")) (
        args
        // {
          stable = stable;
          unstable = unstable;
        }
      ))

      # .. and as a convenience, automatically pull in e.g. dotfiles/<hostname>/default.nix
      #    here to keep the host specific config files short
    ]
    ++ (if builtins.pathExists hostDotfiles then [ hostDotfiles ] else [ ])
    ++ (if builtins.pathExists hostPackages then [ hostPackages ] else [ ])
    ++ (if builtins.pathExists hostScripts then [ hostScripts ] else [ ]);

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
  home.stateVersion = "23.05";

  home.packages = with pkgs; [
    evince
    fasd
    fd
    file
    gparted
    htop
    hyperfine
    nvd
    pavucontrol
    ranger
    shellcheck
    silver-searcher
    tmux
    unstable.todoist
    tree
    xsel
    yank

    unstable.firefox
    unstable.neovim

    seahorse # For managing gnome-keyring
    nodejs # Needed for neovim+copilot
    bitwarden
    emoji-picker
    comma
    gh
    ripgrep # needed by obsidian.nvim
    just

    unstable.obsidian
    unstable.git-crypt

    # For hyprland
    waybar
    wl-clipboard
  ];

  home.sessionVariables = {
    OLLAMA_ORIGINS="app://obsidian.md*";
  };

  # NOTE: If reverting to regular direnv, remember to reinstall ~/.direnrc
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.nix-index.enable = true;

  services.copyq.enable = true;

  programs.bat = {
    enable = true;
    config.theme = "gruvbox-dark";
  };

  programs.rofi = {
    enable = true;
    theme = "gruvbox-dark";
  };
}
