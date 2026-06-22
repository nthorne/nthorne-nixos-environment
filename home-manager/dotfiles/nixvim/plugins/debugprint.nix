{ ... }: {
  programs.nixvim = {
    plugins = {
      debugprint = {
        enable = true;

        settings.filetypes = {
          robot = {
            left = "Log To Console  \\n";
            right = "";
            mid_var = "\${";
            right_var = "}";
          };
        };
      };
    };
  };
}
