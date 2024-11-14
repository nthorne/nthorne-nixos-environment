{ flake-inputs, ... }:
{
  home.file = {
    ".tmux.conf".source = "${flake-inputs.nthorne-tmux}/.tmux-work.conf";
  };
}
