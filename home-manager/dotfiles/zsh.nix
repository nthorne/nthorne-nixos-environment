{ flake-inputs, ... }:
{
  home.file = {
    ".zsh".source = "${flake-inputs.nthorne-zsh}";
    ".zshrc".source = "${flake-inputs.nthorne-zsh}/.zshrc";
    ".zprofile".source = "${flake-inputs.nthorne-zsh}/.zprofile";
    ".zshenv".source = "${flake-inputs.nthorne-zsh}/.zshenv";
  };
}
