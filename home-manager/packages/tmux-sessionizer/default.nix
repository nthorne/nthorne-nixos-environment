{pkgs, ...}: let
  # Perhaps not entirely tied to sessionizer, but making it easier to
  # start sesssions kinda makes this a requirement.
  tmux-boom = pkgs.writeShellApplication {
    name = "tmux-boom";
    runtimeInputs = [pkgs.bashInteractive];
    text = ''
      #!/usr/bin/env bash
      # Send Ctrl-d to all panes, except the current one.
      current_pane=$(tmux display-message -p '#{pane_id}')
      for pane in $(tmux list-panes -a -F '#{pane_id}'); do
          if [[ "$pane" != "$current_pane" ]]; then
              tmux send-keys -t "$pane" C-d
          fi
      done
    '';
  };
in {
  home.packages = with pkgs; [
    tmux-boom
    tmux-sessionizer
  ];

  home.file.".config/tms/config.toml" = {
    text = ''
      [[search_dirs]]
      path = "/home/nthorne/src"
      depth = 2

      [[search_dirs]]
      path = "/home/nthorne/src/prototypes/"
      depth = 2

      [[search_dirs]]
      path = "/home/nthorne/repos"
      depth = 2
    '';
  };

  programs.tmux.extraConfig = ''
    bind t display-popup -E "tms"
    bind T display-popup -E "tms switch"
    bind W display-popup -E "tms windows"
    bind b confirm-before -p "Send Ctrl-d to all panes? (y/n)" "run tmux-boom"
  '';
}
