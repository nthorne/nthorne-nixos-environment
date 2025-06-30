{
  pkgs,
  flake-inputs,
  ...
}: let
  # TODO: Drop this one once the official package catches up.
  gemini-cli-latest = pkgs.gemini-cli.overrideAttrs (final: previous: rec {
    version = "0.1.7";
    src = pkgs.fetchFromGitHub {
      owner = "google-gemini";
      repo = "gemini-cli";
      rev = "19d2a0fb35ff75ebbed2dda5c8574ffcc66cd4d5";
      sha256 = "sha256-DAenod/w9BydYdYsOnuLj7kCQRcTnZ81tf4MhLUug6c=";
    };
    # Set to empy string to get hash
    npmDepsHash = "sha256-otogkSsKJ5j1BY00y4SRhL9pm7CK9nmzVisvGCDIMlU=";
    npmDeps = pkgs.fetchNpmDeps {
      inherit src;
      name = "${previous.pname}-${version}-npm-deps";
      hash = npmDepsHash;
    };
  });
in {
  imports = [
    flake-inputs.sops-nix.homeManagerModules.sops
  ];
  home.packages = with pkgs; [
    bitwarden
    gemini-cli-latest
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
