{pkgs, ...} @ args: let
  secretsFolders = builtins.toString args.flake-inputs.nix-secrets;

  # Override lnav with specific commit. Revert to whatever is in unstable
  # once the new release (0.13.0) has hit the unstable channel.
  lnavOverride = pkgs.lnav.overrideAttrs (oldAttrs: {
    src = pkgs.fetchFromGitHub {
      owner = "tstack";
      repo = "lnav";
      rev = "9ba78a99cf38d39b32f9e1a50974450ccf90db4b";
      sha256 = "sha256-Hsp745LMrTZERaOxM5W4pqoWuDNZLcYWBrRUSZUGVPQ=";
    };
  });
in {
  imports = [
    (import ./packages/clion args)
    (import ./packages/clamav-scan args)

    args.flake-inputs.sops-nix.homeManagerModules.sops
  ];

  home.packages = with pkgs; [
    cppcheck
    ctags
    gdb
    insomnia
    jq
    lnavOverride
    nvtopPackages.full
    p7zip
    remmina
    rr
    slack
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
    };
  };

  programs.ssh = {
    enable = true;

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
    };
  };
}
