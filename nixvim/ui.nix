{ pkgs }:
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

    bufferline = {
      enable = true;
      settings.options = {
        mode = "buffers";
        diagnostics = "nvim_lsp";
        always_show_bufferline = false;
        show_buffer_close_icons = false;
        show_close_icon = false;
        separator_style = "thin";
        diagnostics_indicator.__raw = ''
          function(_, _, diag)
            local icons = { error = " ", warning = " ", info = " " }
            local ret = (diag.error and icons.error .. diag.error .. " " or "")
              .. (diag.warning and icons.warning .. diag.warning or "")
            return vim.trim(ret)
          end
        '';
        offsets = [
          {
            filetype = "snacks_layout_box";
            text = "  󰉋 Explorer";
            highlight = "Directory";
            text_align = "left";
          }
        ];
      };
    };

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

    tiny-inline-diagnostic = {
      enable = true;
      settings = {
        preset = "modern";
        transparent_bg = false;
        options = {
          show_source.enabled = true;
          multilines = {
            enabled = true;
            always_show = false;
          };
          show_all_diags_on_cursorline = true;
          throttle = 40;
        };
      };
    };

    statuscol = {
      enable = true;
      settings = {
        relculright = true;
        segments.__raw = ''
          {
            { text = { require("statuscol.builtin").foldfunc }, click = "v:lua.ScFa" },
            { text = { "%s" }, click = "v:lua.ScSa" },
            { text = { require("statuscol.builtin").lnumfunc, " " }, condition = { true, require("statuscol.builtin").not_empty }, click = "v:lua.ScLa" },
          }
        '';
      };
    };

    noice = {
      enable = true;
      settings = {
        lsp = {
          override = {
            "vim.lsp.util.convert_input_to_markdown_lines" = true;
            "vim.lsp.util.stylize_markdown" = true;
          };
          signature.auto_open.enabled = false; # Handled by blink-cmp signature
        };
        presets = {
          bottom_search = true;
          command_palette = true;
          long_message_to_split = true;
          inc_rename = true;
          lsp_doc_border = true;
        };
        routes = [
          {
            filter = {
              event = "msg_show";
              any = [
                { find = "%d+L, %d+B"; }
                { find = "; after #%d+"; }
                { find = "; before #%d+"; }
                { find = "%d+ fewer lines"; }
                { find = "%d+ more lines"; }
              ];
            };
            opts.skip = true;
          }
        ];
      };
    };

    treesitter-context = {
      enable = true;
      settings = {
        max_lines = 3;
        multiline_threshold = 1;
        trim_scope = "outer";
      };
    };

    rainbow-delimiters.enable = true;

    highlight-colors = {
      enable = true;
      settings = {
        render = "virtual";
        virtual_symbol = "■";
        enable_hex = true;
        enable_short_hex = true;
        enable_rgb = true;
        enable_hsl = true;
        enable_named_colors = true;
        enable_tailwind = true;
      };
    };

    quicker.enable = true;

    snacks = {
      enable = true;
      settings = {
        bigfile.enabled = true;
        quickfile.enabled = true;
        bufdelete.enabled = true;
        explorer.enabled = true;
        lazygit.enabled = true;
        terminal.enabled = true;
        gitbrowse.enabled = true;
        rename.enabled = true;
        notifier = {
          enabled = true;
          timeout = 3000;
          style = "compact";
        };
        indent = {
          enabled = true;
          animate.enabled = true;
          scope.enabled = true;
        };
        scroll = {
          enabled = true;
          animate.duration = { step = 12; total = 180; };
        };
        words.enabled = true;
        zen = {
          enabled = true;
          toggles.dim = true;
          win.width = 110;
        };
        dim.enabled = true;
        scratch.enabled = true;
        image.enabled = true;
        picker = {
          enabled = true;
          sources.files.exclude = [ "bin" "obj" "*.bak-*" ".git" ];
          win = {
            input.keys = {
              "<C-e>" = { __unkeyed-1 = "list_down"; mode = [ "i" "n" ]; };
              "<C-i>" = { __unkeyed-1 = "list_up"; mode = [ "i" "n" ]; };
            };
            list.keys = {
              e = "list_down";
              i = "list_up";
              o = "confirm";
              n = "explorer_close";
              k = "list_down";
              K = "list_up";
            };
          };
        };
        dashboard.__raw = ''
          {
            preset = {
              header = [[
    ███╗   ██╗██╗██╗  ██╗██╗   ██╗██╗███╗   ███╗
    ████╗  ██║██║╚██╗██╔╝██║   ██║██║████╗ ████║
    ██╔██╗ ██║██║ ╚███╔╝ ██║   ██║██║██╔████╔██║
    ██║╚██╗██║██║ ██╔██╗ ╚██╗ ██╔╝██║██║╚██╔╝██║
    ██║ ╚████║██║██╔╝ ██╗ ╚████╔╝ ██║██║ ╚═╝ ██║
    ╚═╝  ╚═══╝╚═╝╚═╝  ╚═╝  ╚═══╝  ╚═╝╚═╝     ╚═╝
       Catppuccin Mocha · Colemak-DH · Neovim 0.12
              ]],
              keys = {
                { icon = " ", key = "f", desc = "Find File",       action = ":lua Snacks.dashboard.pick('files')" },
                { icon = " ", key = "g", desc = "Grep Text",       action = ":lua Snacks.dashboard.pick('live_grep')" },
                { icon = " ", key = "r", desc = "Recent Files",    action = ":lua Snacks.dashboard.pick('oldfiles')" },
                { icon = "󰛢 ", key = "h", desc = "Harpoon Files",   action = ":lua local h=require('harpoon'); h.ui:toggle_quick_menu(h:list())" },
                { icon = " ", key = "s", desc = "Restore Session", section = "session" },
                { icon = "󱄅 ", key = "n", desc = "NixOS Config",    action = ":lua Snacks.picker.files({ cwd = '/etc/nixos' })" },
                { icon = "󰆼 ", key = "d", desc = "SQL Workbench",   action = ":DBUIToggle" },
                { icon = " ", key = "l", desc = "LeetCode (C#)",   action = ":Leet" },
                { icon = " ", key = "c", desc = "New File",        action = ":ene | startinsert" },
                { icon = " ", key = "q", desc = "Quit",            action = ":qa" },
              },
            },
            sections = {
              { section = "header" },
              { section = "keys", gap = 1, padding = 1 },
              { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1, limit = 6 },
              { icon = " ", title = "Projects",     section = "projects",     indent = 2, padding = 1, limit = 5 },
            },
          }
        '';
      };
    };
  };
}
