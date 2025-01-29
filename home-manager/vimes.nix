{stable, ...} @ args: {
  imports = [(import ./packages/clion args)];

  home.packages = with stable; [
    bashdb
    cppcheck
    ctags
    gdb
    glances
    insomnia
    jq
    kdiff3
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
