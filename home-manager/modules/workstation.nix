{
  pkgs,
  flake-inputs,
  ...
}: let
in {
  imports = [
    flake-inputs.sops-nix.homeManagerModules.sops
    ../packages/opencode
  ];
  home.packages = with pkgs; [
    gh
    gparted
    grimblast # Screen capture tool with hyprland support
    libnotify
    obsidian
    openpomodoro-cli
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
