{ ... }: {
  programs.nixvim.plugins.markdown-preview = {
    enable = true;
    settings = {
      preview_options = {
        disable_sync_scroll = 1;
      };
      theme = "dark";
    };
  };
}
