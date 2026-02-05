{pkgs, ...}: {
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

# Window switching
bind Tab last-window

# Open AI agent in a popup at current pane path
bind i display-popup -E -d '#{pane_current_path}' -w 80% -h 80% 'opencode'
# Open AI agent in a new split, to the right of current pane
bind I split-window -h -c '#{pane_current_path}' -p 40 'opencode'

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

set-option -g display-time 4000

#   configurations
set -g @resurrect-processes 'ssh'

set-option -g detach-on-destroy on

set -g @fingers-skip-health-check '1'

run-shell ${pkgs.tmuxPlugins.cpu}/share/tmux-plugins/cpu/cpu.tmux

bind f run -b "#{@fingers-cli} start #{pane_id}"
    '';
  };
}
