{
  pkgs,
  ...
} @ args: let
  secretsFolders = builtins.toString args.flake-inputs.nix-secrets;
in {
  imports = [
    ../../dotfiles/clion.nix
    (import ../../packages/clamav-scan args)
    (import ../workstation.nix args)
    (import ../../scripts/tf2rem args)
    (import ../../dotfiles/vimes/gh-cli args)

    args.flake-inputs.sops-nix.homeManagerModules.sops
  ];

  home.packages = with pkgs; [
    cppcheck
    ctags
    entr
    gdb
    github-copilot-cli
    insomnia
    libxml2
    lnav
    nvtopPackages.full
    p7zip
    remmina
    rr
    slack
    tmuxinator
    ungoogled-chromium
    wget
  ];

  sops = {
    age.keyFile = "/home/nthorne/.config/sops/age/keys.txt";
    defaultSopsFile = "${secretsFolders}/secrets.yaml";

    secrets = {
      "vimes/ssh_keys/rsa_pub".path = "/home/nthorne/.ssh/id_rsa.pub";
      "vimes/ssh_keys/rsa_secret".path = "/home/nthorne/.ssh/id_rsa";
      "vimes/ssh_keys/ed_pub".path = "/home/nthorne/.ssh/id_ed25519.pub";
      "vimes/ssh_keys/ed_secret".path = "/home/nthorne/.ssh/id_ed25519";
      "all/atuin/key".path = "/home/nthorne/.local/share/atuin/key";
      "all/atuin/session".path = "/home/nthorne/.local/share/atuin/session";
    };
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    matchBlocks = {
      "work.github.com" = {
        hostname = "github.com";
        identityFile = "/home/nthorne/.ssh/id_ed25519";
      };
      "github.com" = {
        hostname = "github.com";
        identityFile = "/home/nthorne/.ssh/id_rsa";
      };
      "pa-test-op-mac1" = {
        hostname = "192.168.102.248";
        user = "ture";
      };
      "farmer-agent-0-ubuntu2204" = {
        hostname = "nthorne-agent-0-ubuntu2204.swedencentral.cloudapp.azure.com";
        user = "adminuser";
        identityFile = "/home/nthorne/.ssh/id_ed25519";
        # No point in saving these fingerprints since machines are rebuilt all the time
        extraOptions = {
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
        };
      };
      "farmer-agent-0-ubuntu2404" = {
        hostname = "nthorne-agent-0-ubuntu2404.swedencentral.cloudapp.azure.com";
        user = "adminuser";
        identityFile = "/home/nthorne/.ssh/id_ed25519";
        # No point in saving these fingerprints since machines are rebuilt all the time
        extraOptions = {
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
        };
      };
    };
  };

  programs.zsh.shellAliases = {
    nlsh = ''nlsh() { curl -s localhost:11434/api/generate -d "{\"model\": \"westenfelder/NL2SH\", \"prompt\": \"$1\", \"stream\": false}" | jq -r '.response'}; nlsh'';
  };
}
