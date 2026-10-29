_: {
  programs.nixvim = {
    plugins = {
      lualine = {
        enable = true;
        settings.options.theme = "gruvbox";

        settings.sections.lualine_x = [
          {
            __raw = ''
          function()
            local word = vim.fn.expand("<cword>")

            -- keep only hex digits
            local hex = word:gsub("[^0-9a-fA-F]", "")

            if hex == "" then
              return ""
            end

            local n = tonumber(hex, 16)
            if not n then
              return ""
            end

            return string.format("%d (0x%X)", n, n)
          end
            '';
          }
        ];
      };
    };
  };
}
