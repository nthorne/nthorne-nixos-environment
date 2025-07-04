# This derivation should contain configurations that are common
# to all profiles.
args @ {
  pkgs,
  flake-inputs,
  ...
}: let
  hostname = flake-inputs.hostname;

  hostCollection = path: (path + ("/" + hostname));
  hostDotfiles = hostCollection ./dotfiles;
  hostPackages = hostCollection ./packages;
  hostScripts = hostCollection ./scripts;
  hostModules = hostCollection ./modules;
in {
  imports =
    [
      ./dotfiles/zsh.nix
      ./dotfiles/waybar.nix
      ./dotfiles/hyprlock.nix
      ./dotfiles/hypridle.nix
      (import ./dotfiles/hyprland.nix args)
      (import ./dotfiles/tmux.nix args)

      flake-inputs.nixvim.homeManagerModules.nixvim
      ./dotfiles/nixvim

      ./packages/tmux-sessionizer

      # .. and as a convenience, automatically pull in e.g. dotfiles/<hostname>/default.nix
      #    here to keep the host specific config files short
    ]
    ++ (
      if builtins.pathExists hostDotfiles
      then [hostDotfiles]
      else []
    )
    ++ (
      if builtins.pathExists hostPackages
      then [hostPackages]
      else []
    )
    ++ (
      if builtins.pathExists hostScripts
      then [hostScripts]
      else []
    )
    ++ (
      if builtins.pathExists hostModules
      then [hostModules]
      else []
    );

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
    comma
    eza
    fasd
    fd
    file
    fzf
    htop
    just
    jq
    jqp
    nvd
    pavucontrol
    seahorse # For managing gnome-keyring
    shellcheck
    silver-searcher
    swaynotificationcenter
    tree
    firefox
    git-crypt
    waybar
    wl-clipboard
  ];

  # NOTE: If reverting to regular direnv, remember to reinstall ~/.direnrc
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.nix-index.enable = true;

  programs.ghostty = {
    enable = true;
    clearDefaultKeybinds = true;
    settings = {
      font-family = ["" "JetBrains Mono"];
    };
  };

  programs.bat.enable = true;

  programs.rofi.enable = true;

  programs.atuin = {
    enable = true;
    settings = {
      # ALT key is taken by Hyprland..
      ctrl_n_shortcuts = true;
      enter_accept = true;
      filter_mode = "host";
      filter_mode_shell_up_key_binding = "directory";
    };
  };

  nix.gc = {
    automatic = true;
    options = "--delete-older-than 21d";
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
}
