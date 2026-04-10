{...}: {
  programs.nixvim = { 
    plugins = {
      repeat.enable = true;
      vim-surround.enable = true;
    };

    # used by vim-surround to add markdown code block surround
    # when having visual selection and pressing S followed by <CR>
    globals = {
      surround_13 = "```\n\r\n```";
    };
  };
}
