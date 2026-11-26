{ ... }:

{
  plugins.which-key = {
    enable = true;
    settings = {
      preset = "helix";
      delay = 250;
      win.border = "rounded";
      spec.__raw = ''
        {
          {
            mode = { "n", "x" },
            { "<leader>b", group = "buffer", icon = "󰓩" },
            { "<leader>c", group = "code", icon = "" },
            { "<leader>d", group = "debug", icon = "" },
            { "<leader>D", group = "database", icon = "󰆼" },
            { "<leader>f", group = "file/find", icon = "" },
            { "<leader>g", group = "git", icon = "󰊢" },
            { "<leader>gh", group = "hunks", icon = "" },
            { "<leader>h", group = "harpoon", icon = "󰛢" },
            { "<leader>o", group = "otter", icon = "󰻞" },
            { "<leader>q", group = "session", icon = "󰆓" },
            { "<leader>r", group = "refactor/run", icon = "" },
            { "<leader>s", group = "search", icon = "󰍉" },
            { "<leader>t", group = "test", icon = "󰙨" },
            { "<leader>u", group = "ui toggles", icon = "" },
            { "<leader>w", group = "windows", icon = "" },
            { "<leader>x", group = "diagnostics", icon = "󱖫" },
            { "[", group = "prev" },
            { "]", group = "next" },
            { "g", group = "goto" },
            { "gp", group = "peek (glance)" },
            { "gs", group = "surround" },
            { "z", group = "fold" },
          },
        }
      '';
    };
  };
}
