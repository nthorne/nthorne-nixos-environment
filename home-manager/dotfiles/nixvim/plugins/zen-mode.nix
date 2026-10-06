{ ... }: {
  programs.nixvim.plugins = {
    twilight.enable = true;

    zen-mode = {
      enable = true;
      settings.window = {
        width = 0.75;
        options = {
          signcolumn = "no";
          number = false;
          relativenumber = false;
        };
      };
    };
  };
}
