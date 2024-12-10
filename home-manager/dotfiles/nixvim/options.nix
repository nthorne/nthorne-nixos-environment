{ ... }:
{
  programs.nixvim = {
    enable = true;

    globalOpts = {
      autoindent = true;
      backspace = "indent,eol,start";
      expandtab = true;
      hidden = true;
      hlsearch = true;
      ignorecase = true;
      incsearch = true;
      mouse = "a";
      number = true;
      relativenumber = true;
      smartcase = true;
      smartindent = true;
      sts = 2;
      sw = 2;
    };

    colorschemes.gruvbox.enable = true;
  };
}
