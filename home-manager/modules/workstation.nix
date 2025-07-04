{
  pkgs,
  flake-inputs,
  ...
}: let
in {
  imports = [
    flake-inputs.sops-nix.homeManagerModules.sops
  ];
  home.packages = with pkgs; [
    bitwarden
    gemini-cli
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

  sops.secrets = {
    dot-env = {
      format = "binary";
      sopsFile = ./secrets/gemini-dotenv;
      path = "/home/nthorne/.env";

      mode = "0440";
    };
  };
}
