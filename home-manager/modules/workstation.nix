{pkgs, ...}: {
  home.packages = with pkgs; [
    bitwarden
    gh
    gparted
    grimblast # Screen capture tool with hyprland support
    hyperfine
    libnotify
    obsidian
    openpomodoro-cli
    todoist
  ];

  home.sessionVariables = {
    OLLAMA_ORIGINS = "app://obsidian.md*";
  };

  home.file.".pomodoro/hooks/stop" = {
    text = ''
#!/usr/bin/env bash
set -ueo pipefail
notify-send -et 10000 "Time is up ⏰"
    '';
    executable = true;
  };
}
