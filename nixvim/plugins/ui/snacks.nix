{ ... }:

{
  plugins = {
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
