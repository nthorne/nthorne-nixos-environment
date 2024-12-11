{stable, ...} @ args: {
  imports = [(import ./packages/clion args)];

  home.packages = with stable; [
    bashdb
    cppcheck
    ctags
    gdb
    glances
    insomnia
    kdiff3
    lnav
    p7zip
    rr
    slack
    wget
    ungoogled-chromium
    nvtopPackages.full
    jq
  ];
}
