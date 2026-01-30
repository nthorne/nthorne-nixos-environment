{...}: {
  programs.nixvim.plugins.bullets = {
    enable = true;

    settings = {
      enabled_file_types = ["gitcommit" "text" "scratch" "markdown"];
    };
  };
}
