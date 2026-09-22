{
  lib,
  pkgs,
  ...
}:
{
  home.packages = with pkgs; [
    (writeShellScriptBin "tmux-boom" ''
      # Send Ctrl-d to all panes, except the current one.
      # Anything that does not terminate on EOF will need to be shut down manually.
      current_pane=$(tmux display-message -p '#{pane_id}')
      for pane in $(tmux list-panes -a -F '#{pane_id}'); do
          if [[ "$pane" != "$current_pane" ]]; then
              tmux send-keys -t "$pane" C-d
          fi
      done
    '')
  ];

  programs.tmux = {
    enable = true;

    plugins = with pkgs.tmuxPlugins; [
      cpu
      fingers
      open
      sessionist
      vim-tmux-navigator
      yank
    ];

    extraConfig = ''
      # Set prefix to good old C-a to avoid confusion
      set -g prefix C-a
      unbind C-b

      #reduce the command delay
      set -s escape-time 1

      bind C-a send-prefix

      # Rebind new-window to get the default-path behavior
      bind c new-window -c '#{pane_current_path}'
      # "up" path new pane strategy
      bind u new-window -c '#{pane_current_path}/..'
      # "home" path new pane strategy
      bind h new-window -c '~'

      # Define saner window splitting keys
      bind | split-window -c '#{pane_current_path}' -h
      bind - split-window -c '#{pane_current_path}' -v

      # Vim-like movement between panes..
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # .. and between windows
      bind -r C-h select-window -t :-
      bind -r C-l select-window -t :+

      # .. and for resizing panes
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5

      # Use vim-ish copy-mode
      unbind [
      unbind ]
      bind Escape copy-mode
      bind p paste-buffer
      bind-key -T copy-mode-vi 'v' send -X begin-selection 
      bind-key -T copy-mode-vi 'y' send -X copy-selection

      # Fast cd to git root
      bind C-g run "tmux set-buffer \"$(git rev-parse --show-toplevel)\"; tmux paste-buffer"

      # Clipboard interaction
      bind C-y run "tmux save-buffer - | wl-copy"
      bind C-p run "tmux set-buffer \"$(wl-paste -n)\"; tmux paste-buffer"

      bind P pipe-pane -o "cat >>~/#W.log"\; display "Toggled logging to ~/#W.log" 

      # Use § to toggle prefix key; makes working in nested tmux sessions a lot nicer.
      bind -T root §  \
        set prefix None \;\
        set key-table off \;\
        if -F '#{pane_in_mode}' 'send-keys -X cancel' \;\
        refresh-client -S \;\

      bind -T off § \
        set -u prefix \;\
        set -u key-table \;\
        set -u status-style \;\
        set -u window-status-current-style \;\
        set -u window-status-current-format \;\
        refresh-client -S

      bind s setw synchronize-pane

      # Quick and dirty file pickers. C-d for directories, C-f for files, and C-h for both, but starting in my home directory with absolute paths.
      bind-key C-d display-popup -d '#{pane_current_path}' -E '${lib.getExe pkgs.fd} -t d | ${lib.getExe pkgs.fzf} | tmux load-buffer - ' \; paste-buffer -d
      bind-key C-f display-popup -d '#{pane_current_path}' -E '${lib.getExe pkgs.fd} -t f | ${lib.getExe pkgs.fzf} | tmux load-buffer - ' \; paste-buffer -d
      bind-key C-h display-popup -d '/home/nthorne' -E '${lib.getExe pkgs.fd} -a | ${lib.getExe pkgs.fzf} | tmux load-buffer - ' \; paste-buffer -d

      # Window switching
      bind Tab last-window

      # Open AI agent keybindings: prefix+i to open the agent binding table ..
      bind -T prefix i switch-client -T pi-agent-table
      # .. and then | for horizontal split, - for vertical split, and p for popup.
      bind -T pi-agent-table | split-window -h -c '#{pane_current_path}' -p 40 'pi'
      bind -T pi-agent-table - split-window -v -c '#{pane_current_path}' -p 40 'pi'
      bind -T pi-agent-table p display-popup -E -d '#{pane_current_patinstall h}' -w 80% -h 80% 'pi'

      bind b confirm-before -p "Send Ctrl-d to all panes? (y/n)" "run tmux-boom"

      # use 256 color display
      set -g default-terminal "screen-256color"

      set -g status-right-length 64

      # Monitor activity in other windows
      setw -g monitor-activity on
      set -g visual-activity on

      # recommended by vim.health
      set -g focus-events on

      # Put some useful information on status bar
      set -g status-right "#[attr=bright]#[fg=orange]#([ $(tmux show-option -qv key-table) = 'off' ] && echo 'Prefix OFF|')CPU: #{cpu_percentage}|BATTERY: #(cat /sys/class/power_supply/BAT0/capacity)%#[fg=yellow]|load:#(cut -d' ' -f1-3 /proc/loadavg)|#[attr=bright]#[fg=green]#(date +'%Y-%m-%d %H:%M')"

      # Set a decent status bar refresh rate
      set -g status-interval 3

      setw -g mode-keys vi

      # Mostly for pi
      set -g extended-keys on
      set -g extended-keys-format csi-u
      set -g set-clipboard on

      set-option -g display-time 4000

      #   configurations
      set -g @resurrect-processes 'ssh'

      set-option -g detach-on-destroy on

      set -g @fingers-skip-health-check '1'

      run-shell ${pkgs.tmuxPlugins.cpu}/share/tmux-plugins/cpu/cpu.tmux

      bind f run -b "#{@fingers-cli} start #{pane_id}"

      # I often get black on black for pane numbers, so let's set a bright color for them
      set -g display-panes-active-colour "#fabd2f" # gruvbox yellow
      set -g display-panes-colour "#a89984"        # gruvbox muted gray
    '';
  };
}
