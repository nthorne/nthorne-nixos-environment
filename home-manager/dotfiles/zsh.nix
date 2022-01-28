{ pkgs, ...}:
{
  # TODO: Maybe there's a neater way to to this, since the
  #   zsh folder is already in the store..
  home.file = {
    ".zsh".source = ./zsh;
    ".zshrc".source = ./zsh/.zshrc;
    ".zprofile".source = ./zsh/.zprofile;
    ".zshenv".source = ./zsh/.zshenv;
  };
}

