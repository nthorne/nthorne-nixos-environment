{stable, ...} @ args: {
  imports = [
    (import ./packages/clion args)
    (import ./packages/clamav-scan args)
  ];

  home.packages = with stable; [
    cppcheck
    ctags
    gdb
    insomnia
    jq
    lnav
    nvtopPackages.full
    p7zip
    remmina
    rr
    slack
    ungoogled-chromium
    wget
  ];

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
