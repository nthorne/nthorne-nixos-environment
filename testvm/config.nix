{
  packageOverrides = pkgs_: with pkgs_; {
    all = with pkgs; buildEnv {
      name = "all";
      paths = [
      	tmux
        ag
	firefox
        fzf                  # Used by neovim config
        conky                # Used by xmonad config
        dzen2                # Used by xmonad config
        "terminus-font-4.40" # Used by xmonad config
      ];
    };
  };
}
