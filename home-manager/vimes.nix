{stable, ...}: {
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
    slock
    wget
    xdotool
    xorg.xbacklight
    ungoogled-chromium
    nvtopPackages.full
    jq
  ];
}
