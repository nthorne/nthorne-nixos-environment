{ ... }:
{
  programs.nixvim = {
    plugins.render-markdown.enable = true;

    # Make bold text a bit more visible by using the same
    # highlight group as markdownH2, and making it bold.
    extraConfigLua = ''
      local h2 = vim.api.nvim_get_hl(0, { name = "markdownH2" })
      h2.bold = true
      vim.api.nvim_set_hl(0, "@markup.strong", h2)
    '';
  };
}
