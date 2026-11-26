{ ... }:

{
  plugins = {
    dropbar = {
      enable = true;
      settings = {
        bar.enable.__raw = ''
          function(buf, win, _)
            if not vim.api.nvim_buf_is_valid(buf) or not vim.api.nvim_win_is_valid(win) then return false end
            if vim.fn.win_gettype(win) ~= "" then return false end
            local ft = vim.bo[buf].filetype
            local bt = vim.bo[buf].buftype
            if bt ~= "" or ft == "oil" or ft == "snacks_dashboard" or ft == "TelescopePrompt" then return false end
            return true
          end
        '';
        menu.keymaps = {
          e = "<Down>";
          i = "<Up>";
          o = "<CR>";
          n = "<Esc>";
        };
      };
    };
  };
}
