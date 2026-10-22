# This derivation should contain configurations that are common
# to all profiles.
args@{
  flake-inputs,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  inherit (flake-inputs) hostname;

  hostDir = ./hosts + "/${hostname}";
  hostCollection = name: hostDir + "/${name}";
  hostDotfiles = hostCollection "dotfiles";
  hostPackages = hostCollection "packages";
  hostScripts = hostCollection "scripts";
  hostModules = hostDir;

  # Not all hosts use a window manager (hyprland), so we
  # trim installed derivations and files accordingly.
  wmEnabled = osConfig.programs.hyprland.enable or false;
in
{
  imports = [
    ./dotfiles/zsh.nix
    (import ./dotfiles/tmux.nix args)

    flake-inputs.nix-index-database.homeModules.default
    {
      programs.nix-index-database.comma.enable = true;
    }

    flake-inputs.nixvim.homeModules.nixvim
    ./dotfiles/nixvim

    ./packages/tmux-sessionizer

    # .. and as a convenience, automatically pull in e.g. hosts/<hostname>/dotfiles/default.nix
    #    here to keep the host specific config files short
  ]
  ++ lib.optionals wmEnabled [
    ./dotfiles/waybar.nix
    ./dotfiles/hyprlock.nix
    ./dotfiles/hypridle.nix
    (import ./dotfiles/hyprland.nix args)
  ]
  ++ (if builtins.pathExists hostDotfiles then [ hostDotfiles ] else [ ])
  ++ (if builtins.pathExists hostPackages then [ hostPackages ] else [ ])
  ++ (if builtins.pathExists hostScripts then [ hostScripts ] else [ ])
  ++ (if builtins.pathExists hostModules then [ hostModules ] else [ ]);

  config = {

    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    home = {
      username = "nthorne";
      homeDirectory = "/home/nthorne";

      # This value determines the Home Manager release that your
      # configuration is compatible with. This helps avoid breakage
      # when a new Home Manager release introduces backwards
      # incompatible changes.
      #
      # You can update Home Manager without changing this value. See
      # the Home Manager release notes for a list of state version
      # changes in each release.
      stateVersion = "23.05";

      packages =
        with pkgs;
        [
          eza
          fd
          file
          fzf
          git-crypt
          htop
          jq
          jqp
          just
          nvd
          shellcheck
          tree
          wl-clipboard
        ]
        ++ lib.optionals wmEnabled [
          pavucontrol
          seahorse # For managing gnome-keyring
          swaynotificationcenter
          waybar
        ];

      pointerCursor.enable = true;
    };

    programs = {
      # Let Home Manager install and manage itself.
      home-manager.enable = true;

      # NOTE: If reverting to regular direnv, remember to reinstall ~/.direnrc
      direnv.enable = true;
      direnv.nix-direnv.enable = true;

      ghostty = {
        enable = true;
        clearDefaultKeybinds = true;
        settings = {
          font-family = [
            ""
            "JetBrainsMono Nerd Font"
          ];

          keybind = [
            "ctrl+plus=increase_font_size:1"
            "ctrl+-=decrease_font_size:1"
            "ctrl+0=reset_font_size"
          ];
        };
      };

      bat.enable = true;

      rofi.enable = wmEnabled;

      atuin = {
        enable = true;
        settings = {
          # ALT key is taken by Hyprland..
          ctrl_n_shortcuts = true;
          enter_accept = true;
          filter_mode = "host";
          filter_mode_shell_up_key_binding = "directory";
        };
      };

      starship = {
        enable = true;
        enableZshIntegration = true;
      };

      ripgrep = {
        enable = true;
        arguments = [
          "--smart-case"
        ];
      };

      zoxide = {
        enable = true;
        enableZshIntegration = true;
      };
    };

    nix.gc = {
      automatic = true;
      options = "--delete-older-than 21d --keep-generations 5";
    };
  };
}
