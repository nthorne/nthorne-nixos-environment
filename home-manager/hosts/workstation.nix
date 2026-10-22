{
  pkgs,
  flake-inputs,
  ...
}:
{
  imports = [
    flake-inputs.sops-nix.homeManagerModules.sops
    ../packages/opencode
  ];

  sops = {
    age.keyFile = "/home/nthorne/.config/sops/age/keys.txt";
    defaultSopsFile = "${toString flake-inputs.nix-secrets}/secrets.yaml";

    secrets = {
      "all/atuin/key".path = "/home/nthorne/.local/share/atuin/key";
      "all/atuin/session".path = "/home/nthorne/.local/share/atuin/session";
    };
  };

  home.packages = with pkgs; [
    gh
    gparted
    grimblast # Screen capture tool with hyprland support
    libnotify
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

  programs.firefox = {
    enable = true;
  };
  stylix.targets.firefox = {
    enable = true;
    profileNames = [
      "default"
    ];
    firefoxGnomeTheme.enable = true;
  };
}
