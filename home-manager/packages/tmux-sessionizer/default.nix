{pkgs, ...}: {
  home.packages = [
    pkgs.tmux-sessionizer
  ];

  home.file.".config/tms/config.toml" = {
    text = ''
      [[search_dirs]]
      path = "/home/nthorne/src"
      depth = 1

      [[search_dirs]]
      path = "/home/nthorne/repos"
      depth = 1
    '';
  };

  programs.tmux.extraConfig = ''
    bind t display-popup -E "tms"
    bind T display-popup -E "tms switch"
    bind W display-popup -E "tms windows"
  '';
}
