{ pkgs, ...}:
{
  home.file = {
    ".tmux.conf".source = ./../tmux/.tmux-work.conf;
  };
}

