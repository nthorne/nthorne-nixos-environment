{
  pkgs,
  ...
} @ args: let
  secretsFolders = toString args.flake-inputs.nix-secrets;
in {
  imports = [
    (import ../workstation.nix args)
    (import ../../scripts/tf2rem args)
    (import ../../dotfiles/vimes/gh-cli args)

    ../../packages/copilot-cli

    args.flake-inputs.sops-nix.homeManagerModules.sops
  ];

  home.packages =
    with pkgs;
    [
      ctags
      entr
      gdb
      insomnia
      libxml2
      lnav
      nvtopPackages.full
      p7zip
      remmina
      tmuxinator
      wget
    ]
    ++ [
      (pkgs.callPackage ../../packages/open-ralph-wiggum { })
    ];

  sops = {
    age.keyFile = "/home/nthorne/.config/sops/age/keys.txt";
    defaultSopsFile = "${secretsFolders}/secrets.yaml";

    secrets = {
      "vimes/ssh_keys/rsa_pub".path = "/home/nthorne/.ssh/id_rsa.pub";
      "vimes/ssh_keys/rsa_secret".path = "/home/nthorne/.ssh/id_rsa";
      "all/atuin/key".path = "/home/nthorne/.local/share/atuin/key";
      "all/atuin/session".path = "/home/nthorne/.local/share/atuin/session";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      "github.com" = {
        hostname = "github.com";
        identityFile = "/home/nthorne/.ssh/id_rsa";
      };
    };
  };

  programs.zsh.shellAliases = {
    nlsh = ''nlsh() { curl -s localhost:11434/api/generate -d "{\"model\": \"westenfelder/NL2SH\", \"prompt\": \"$1\", \"stream\": false}" | jq -r '.response'}; nlsh'';
  };

  programs.opencode.settings.provider.ollama.models = {
    "gemma4:latest" = {
      name = "gemma4:latest";
    };
    "qwen3-coder:latest" = {
      name = "qwen3-coder:latest";
    };
    "qwen3.5:latest" = {
      name = "qwen3.5:latest";
    };
  };
}
