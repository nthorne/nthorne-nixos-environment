{pkgs, ...}: {
  home.packages = with pkgs; [
    bitwarden
    gh
    gparted
    grimblast # Screen capture tool with hyprland support
    hyperfine
    libnotify
    obsidian
    todoist
  ];

  home.sessionVariables = {
    OLLAMA_ORIGINS = "app://obsidian.md*";
  };
}
