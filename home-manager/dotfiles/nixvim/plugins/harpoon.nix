{...}: {
  programs.nixvim = {
    plugins.harpoon = {
      enable = true;
      enableTelescope = true;
    };

    extraConfigLua = ''
      local harpoon = require("harpoon")

      harpoon:setup()

      vim.keymap.set("n", "<leader>hm", function() harpoon:list():add() end,
        { desc = "Harpoon [M]ark" })
      vim.keymap.set("n", "<leader>hq", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
        { desc = "Harpoon [Q]uick menu" })

      vim.keymap.set("n", "<leader>h1", function() harpoon:list():select(1) end,
        { desc = "Harpoon [1] Select" })
      vim.keymap.set("n", "<leader>h2", function() harpoon:list():select(2) end,
        { desc = "Harpoon [2] Select" })
      vim.keymap.set("n", "<leader>h3", function() harpoon:list():select(3) end,
        { desc = "Harpoon [3] Select" })
      vim.keymap.set("n", "<leader>h4", function() harpoon:list():select(4) end,
        { desc = "Harpoon [4] Select" })
    '';
  };
}
