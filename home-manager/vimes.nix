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
}
