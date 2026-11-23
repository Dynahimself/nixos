{ pkgs }:
{
  globals = {
    mapleader = " ";
    maplocalleader = " ";
    format_on_save = true;
  };

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

  opts = {
    clipboard = "unnamedplus";
    updatetime = 200;
    timeoutlen = 300;
    termguicolors = true;
    undofile = true;
    undolevels = 10000;
    signcolumn = "yes";
    number = true;
    relativenumber = true;
    cursorline = true;
    expandtab = true;
    tabstop = 2;
    shiftwidth = 2;
    shiftround = true;
    smartindent = true;
    ignorecase = true;
    smartcase = true;
    inccommand = "split";
    splitbelow = true;
    splitright = true;
    showmode = false;
    wrap = false;
    mouse = "a";
    scrolloff = 8;
    sidescrolloff = 8;
    smoothscroll = true;
    confirm = true;
    conceallevel = 2;
    pumheight = 12;
    winborder = "rounded";
    foldcolumn = "1";
    foldlevel = 99;
    foldlevelstart = 99;
    foldenable = true;
    foldmethod = "expr";
    foldexpr = "v:lua.vim.treesitter.foldexpr()";
    foldtext = "v:lua.DynaFoldText()";
    completeopt = [ "menu" "menuone" "noselect" ];
    fillchars = {
      eob = " ";
      foldopen = "▾";
      foldclose = "▸";
      fold = " ";
      foldsep = " ";
      diff = "╱";
    };
  };

  diagnostic.settings = {
    virtual_text = false; # Handled by tiny-inline-diagnostic
    underline = true;
    update_in_insert = false;
    severity_sort = true;
    float = {
      border = "rounded";
      source = true;
    };
    signs.text.__raw = ''
      {
        [vim.diagnostic.severity.ERROR] = " ",
        [vim.diagnostic.severity.WARN]  = " ",
        [vim.diagnostic.severity.INFO]  = " ",
        [vim.diagnostic.severity.HINT]  = "󰌵 ",
      }
    '';
  };

  autoCmd = [
    {
      event = [ "TermOpen" ];
      pattern = [ "*" ];
      command = "startinsert";
    }
    {
      event = [ "TextYankPost" ];
      pattern = [ "*" ];
      callback.__raw = "function() vim.hl.on_yank({ timeout = 160 }) end";
    }
    # Equalize splits on resize
    {
      event = [ "VimResized" ];
      pattern = [ "*" ];
      callback.__raw = "function() local cur = vim.fn.tabpagenr(); vim.cmd('tabdo wincmd ='); vim.cmd('tabnext ' .. cur) end";
    }
    # Restore cursor position
    {
      event = [ "BufReadPost" ];
      pattern = [ "*" ];
      callback.__raw = ''
        function(ev)
          local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
          local lcount = vim.api.nvim_buf_line_count(ev.buf)
          if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
          end
        end
      '';
    }
    # Close help/qf panels with q
    {
      event = [ "FileType" ];
      pattern = [ "help" "qf" "man" "lspinfo" "checkhealth" "notify" "neotest-output" "neotest-output-panel" "neotest-summary" ];
      callback.__raw = ''
        function(ev)
          vim.bo[ev.buf].buflisted = false
          vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true, desc = "Close Panel" })
        end
      '';
    }
  ];
}
