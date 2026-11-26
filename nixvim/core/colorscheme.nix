{ ... }:

{
  colorschemes.catppuccin = {
    enable = true;
    settings = {
      flavour = "mocha";
      transparent_background = true;
      term_colors = true;
      styles = {
        comments = [ "italic" ];
        conditionals = [ "italic" ];
        keywords = [ "bold" ];
        functions = [ "bold" ];
      };
      custom_highlights.__raw = ''
        function(colors)
          return {
            FloatBorder             = { fg = colors.mauve, bg = "NONE" },
            NormalFloat             = { fg = colors.text, bg = "NONE" },
            WinSeparator            = { fg = colors.surface1 },
            CursorLine              = { bg = colors.surface0 },
            CursorLineNr            = { fg = colors.mauve, style = { "bold" } },
            LineNr                  = { fg = colors.overlay0 },
            FoldColumn              = { fg = colors.overlay0, bg = "NONE" },
            Folded                  = { fg = colors.lavender, bg = colors.surface0 },
            BlinkCmpMenu            = { fg = colors.text, bg = colors.mantle },
            BlinkCmpMenuBorder      = { fg = colors.mauve, bg = colors.mantle },
            BlinkCmpMenuSelection   = { fg = colors.mauve, bg = colors.surface0, style = { "bold" } },
            BlinkCmpDoc             = { fg = colors.text, bg = colors.mantle },
            BlinkCmpDocBorder       = { fg = colors.blue, bg = colors.mantle },
            BlinkCmpSignatureHelpBorder = { fg = colors.teal, bg = colors.mantle },
            SnacksPickerBorder      = { fg = colors.mauve, bg = "NONE" },
            SnacksPickerTitle       = { fg = colors.crust, bg = colors.mauve, style = { "bold" } },
            SnacksPickerPreviewTitle = { fg = colors.crust, bg = colors.blue, style = { "bold" } },
            SnacksPickerInputBorder = { fg = colors.lavender, bg = "NONE" },
            SnacksDashboardHeader   = { fg = colors.mauve, style = { "bold" } },
            SnacksDashboardKey      = { fg = colors.peach, style = { "bold" } },
            SnacksDashboardIcon     = { fg = colors.blue },
            SnacksDashboardTitle    = { fg = colors.lavender, style = { "bold" } },
            NoiceCmdlinePopupBorder = { fg = colors.mauve },
            NoiceCmdlineIcon        = { fg = colors.mauve },
            WhichKeyBorder          = { fg = colors.mauve },
            LspInlayHint            = { fg = colors.overlay1, bg = "NONE", style = { "italic" } },
            TreesitterContext       = { bg = colors.mantle },
            TreesitterContextBottom = { sp = colors.surface1, underline = true },
          }
        end
      '';
      integrations = {
        aerial = true;
        blink_cmp = true;
        dap = true;
        dap_ui = true;
        diffview = true;
        dropbar.enabled = true;
        flash = true;
        gitsigns = true;
        grug_far = true;
        harpoon = true;
        lsp_trouble = true;
        mini.enabled = true;
        neotest = true;
        noice = true;
        overseer = true;
        rainbow_delimiters = true;
        render_markdown = true;
        snacks.enabled = true;
        treesitter = true;
        treesitter_context = true;
        which_key = true;
      };
    };
  };
}
