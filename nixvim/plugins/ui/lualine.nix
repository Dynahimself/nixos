{ ... }:

{
  plugins = {
    lualine = {
      enable = true;
      settings = {
        options = {
          globalstatus = true;
          icons_enabled = true;
          theme = "catppuccin";
          component_separators = { left = "·"; right = "·"; };
          section_separators = { left = ""; right = ""; };
          disabled_filetypes.statusline = [ "snacks_dashboard" ];
        };
        sections = {
          lualine_a = [
            {
              __unkeyed-1 = "mode";
              icon = "";
              separator = { left = ""; right = ""; };
            }
          ];
          lualine_b = [
            { __unkeyed-1 = "branch"; icon = ""; }
            {
              __unkeyed-1 = "diff";
              symbols = { added = " "; modified = " "; removed = " "; };
            }
          ];
          lualine_c = [
            { __unkeyed-1 = "filetype"; icon_only = true; padding = { left = 1; right = 0; }; }
            { __unkeyed-1 = "filename"; path = 1; symbols = { modified = " ●"; readonly = " "; unnamed = "[No Name]"; }; }
            {
              __unkeyed-1.__raw = ''
                function()
                  local ok, harpoon = pcall(require, "harpoon")
                  if not ok then return "" end
                  local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
                  for idx, item in ipairs(harpoon:list().items) do
                    if item and item.value == path then
                      return "󰛢 " .. idx
                    end
                  end
                  return ""
                end
              '';
              color = { fg = "#fab387"; gui = "bold"; };
            }
            {
              __unkeyed-1.__raw = ''
                function()
                  local reg = vim.fn.reg_recording()
                  return reg ~= "" and ("󰑋 REC @" .. reg) or ""
                end
              '';
              color = { fg = "#11111b"; bg = "#f38ba8"; gui = "bold"; };
            }
          ];
          lualine_x = [
            {
              __unkeyed-1 = "diagnostics";
              symbols = { error = " "; warn = " "; info = " "; hint = "󰌵 "; };
            }
            { __unkeyed-1 = "overseer"; }
            {
              __unkeyed-1.__raw = ''
                function()
                  local ok, dap = pcall(require, "dap")
                  if ok and dap.status() ~= "" then
                    return " " .. dap.status()
                  end
                  return ""
                end
              '';
              color = { fg = "#f38ba8"; gui = "bold"; };
            }
            {
              __unkeyed-1.__raw = ''
                function()
                  local clients = vim.lsp.get_clients({ bufnr = 0 })
                  if #clients == 0 then return "" end
                  local names = {}
                  for _, c in ipairs(clients) do
                    if c.name ~= "null-ls" then table.insert(names, c.name) end
                  end
                  return " " .. table.concat(names, ",")
                end
              '';
              color = { fg = "#b4befe"; };
            }
            {
              __unkeyed-1.__raw = ''
                function()
                  return vim.g.format_on_save == false and "󰉼 fmt:off" or ""
                end
              '';
              color = { fg = "#f9e2af"; };
            }
            { __unkeyed-1 = "searchcount"; }
          ];
          lualine_y = [
            { __unkeyed-1 = "progress"; }
          ];
          lualine_z = [
            {
              __unkeyed-1 = "location";
              separator = { left = ""; right = ""; };
            }
          ];
        };
      };
    };
  };
}
