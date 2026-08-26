# =====================================================================
# Nixvim port of ~/.config/nvim (LazyVim starter + personal layer)
# migrated 2026-08-16, verbatim semantics where possible
#
# ACTIVATION (when ready):
#   1. home.nix: set nixvimEnabled = true
#   2. mv ~/.config/nvim ~/.config/nvim-lazyvim-backup   (git repo kept)
#   3. sudo nixos-rebuild switch --flake .#desktop
# Rollback = reverse the 3 steps. LazyVim config stays untouched in git.
#
# Notes on the LazyVim → nixvim shift:
#   - Mason is GONE: LSPs/DAPs come from packages.nix (already present)
#     via nixvim's lsp module + PATH.
#   - LazyVim "extras" are replicated below as explicit modules.
#   - Anything without a stable nixvim module is an extraPlugin.
# =====================================================================
{ config, lib, pkgs, ... }:

# Dormant by default — flip `dyna.nixvim.enable = true` in home.nix to use.
# While false, this module evaluates to nothing (safe to keep in imports).
let cfg = config.dyna.nixvim; in
{
  options.dyna.nixvim = {
    enable = lib.mkEnableOption "Nixvim editor (replaces LazyVim)";
  };

  config = lib.mkIf cfg.enable {
  programs.nixvim = {
    enable = true;

    # ================== OPTIONS / GLOBALS ==================
    # mapleader MUST be set before plugins load (which-key, leader maps)
    globals.mapleader = " ";
    globals.maplocalleader = " ";

    colorschemes.catppuccin = {
      enable = true;
      settings.flavour = "mocha"; # whole system is Mocha
    };

    # LazyVim distro defaults (ported 2026-08-26 — these lived in the distro, not user config)
    opts = {
      clipboard = "unnamedplus"; # was set in init.lua
      updatetime = 200; # LazyVim default (snappier)
      termguicolors = true;
      undofile = true;
      signcolumn = "yes";
      # --- LazyVim defaults that were silently missing after the port ---
      number = true; # line numbers
      relativenumber = true; # hybrid line numbers (LazyVim style)
      cursorline = true; # highlight current line
      expandtab = true; # spaces, not tabs
      tabstop = 2;
      shiftwidth = 2;
      shiftround = true;
      smartindent = true;
      ignorecase = true; # + smartcase = case-insensitive unless capitals
      smartcase = true;
      splitbelow = true;
      splitright = true;
      showmode = false; # mode shown by lualine/noice
      wrap = false; # LazyVim default: no soft wrap
      mouse = "a";
      scrolloff = 8;
      sidescrolloff = 8;
      completeopt = [ "menu" "menuone" "noselect" ];
      # LazyVim fillchars — kills the "~" wall beyond EOF
      # (fold glyphs must be exactly 1 char; LazyVim uses nerdfont  that
      #  render invisibly over ssh — using visible equivalents)
      fillchars = {
        eob = " ";
        foldopen = "▾";
        foldclose = "▸";
        fold = " ";
        foldsep = " ";
        diff = "╱";
      };
    };

    # ================== KEYMAPS (colemak home-row, verbatim) ==================
    keymaps = [
      # Directional keys (home row): n=left e=down i=up o=right
      { mode = [ "n" "v" "x" ]; key = "n"; action = "h"; options.desc = "Left"; }
      { mode = [ "n" "v" "x" ]; key = "e"; action = "gj"; options.desc = "Down (wrapped)"; }
      { mode = [ "n" "v" "x" ]; key = "i"; action = "gk"; options.desc = "Up (wrapped)"; }
      { mode = [ "n" "v" "x" ]; key = "o"; action = "l"; options.desc = "Right"; }
      # k/K = search next/prev (formerly n/N)
      { mode = [ "n" "v" "x" ]; key = "k"; action = "n"; options.desc = "Search next"; }
      { mode = [ "n" "v" "x" ]; key = "K"; action = "N"; options.desc = "Search previous"; }
      # j/J = end of word (formerly e/E)
      { mode = [ "n" "v" "x" ]; key = "j"; action = "e"; options.desc = "End of word"; }
      { mode = [ "n" "v" "x" ]; key = "J"; action = "E"; options.desc = "End of word (space)"; }
      # l/L = insert (formerly i/I), h/H = open line (formerly o/O)
      { mode = "n"; key = "l"; action = "i"; options.desc = "Insert"; }
      { mode = "n"; key = "L"; action = "I"; options.desc = "Insert at line start"; }
      { mode = "n"; key = "h"; action = "o"; options.desc = "Open line below"; }
      { mode = "n"; key = "H"; action = "O"; options.desc = "Open line above"; }
      # Window nav on Ctrl + new directionals
      { mode = "n"; key = "<C-n>"; action = "<C-w>h"; options.desc = "Window left"; }
      { mode = "n"; key = "<C-e>"; action = "<C-w>j"; options.desc = "Window down"; }
      { mode = "n"; key = "<C-i>"; action = "<C-w>k"; options.desc = "Window up"; }
      { mode = "n"; key = "<C-o>"; action = "<C-w>l"; options.desc = "Window right"; }
      # Buffers on shift + side-to-side keys
      { mode = "n"; key = "<S-n>"; action = "<cmd>bprevious<cr>"; options.desc = "Prev buffer"; }
      { mode = "n"; key = "<S-o>"; action = "<cmd>bnext<cr>"; options.desc = "Next buffer"; }
      # LazyVim defaults worth keeping
      { mode = "n"; key = "<leader><leader>"; action.__raw = "function() require('snacks').picker.smart() end"; options.desc = "Smart Find Files"; }
      { mode = "n"; key = "<leader>/"; action.__raw = "function() require('snacks').picker.grep() end"; options.desc = "Grep"; }
      { mode = "n"; key = "<leader>e"; action.__raw = "function() require('snacks').explorer() end"; options.desc = "File Explorer"; }
      { mode = "n"; key = "<leader>oa"; action.__raw = "function() require('otter').activate({'javascript','css'}, true, true, nil) end"; options.desc = "Otter Activate (JS/CSS in HTML)"; }
    ];

    # ================== AUTOCMDS ==================
    autoCmd = [
      # Terminal mode auto-insert (was in init.lua)
      {
        event = [ "TermOpen" ];
        pattern = [ "*" ];
        command = "startinsert";
      }
    ];

    # ================== PERSONAL COMMANDS + HTML TEMPLATE + PRESENCE ==================
    # verbatim port of init.lua's vim.api.nvim_* blocks
    extraConfigLua = ''
      -- :Crun for K&R and CS:APP exercises
      -- Bad practices for real projects, fine for single files.
      vim.api.nvim_create_user_command("Crun", function()
        local src = vim.fn.expand("%:p")
        local bin = vim.fn.expand("%:p:r")
        vim.cmd("write")
        vim.cmd("vsplit")
        vim.cmd.terminal(string.format(
          "gcc -Wall -Wextra -std=c99 -o %s %s && %s",
          vim.fn.shellescape(bin), vim.fn.shellescape(src), vim.fn.shellescape(bin)
        ))
        vim.cmd("startinsert")
      end, { desc = "Compile & run C (gcc)" })

      vim.api.nvim_create_user_command("Csrun", function()
        local file = vim.fn.expand("%:p")
        vim.cmd("terminal dotnet run " .. vim.fn.shellescape(file))
      end, {})

      -- HTML '!' template (colemak-safe: triggers only on empty line start)
      vim.api.nvim_create_autocmd("FileType", {
        pattern = "html",
        callback = function()
          vim.keymap.set("i", "!", function()
            local col = vim.api.nvim_win_get_cursor(0)[2]
            local line = vim.api.nvim_get_current_line()
            if line:sub(1, col):match("^%s*$") then
              local template = [[<!DOCTYPE html>
      <html lang="fr">
      <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>Exercice</title>
          <link rel="stylesheet" href="catppuccin.css">
      </head>
      <body>
          <header>
                  <div id="title">
                          <img src="./images/catppuccin.png" alt="Logo Catppuccin" id="logo">
              <h1 id="titleSwitch">
                  <span id="initialTitle">Exercice</span>
                  <span id="hoverTitle"><a href="index.html">Index</a></span>
              </h1>
                  </div>
          </header>
          <main>
            <article>
              <section id="exercice">

              </section>
            </article>
          </main>

          <footer>

          </footer>
            <script>
                "use strict";

            </script>
      </body>
      </html>]]
              vim.snippet.expand(template)
            else
              vim.api.nvim_feedkeys("!", "n", false)
            end
          end, { buffer = true, desc = "HTML template" })
        end,
      })

      -- Discord Rich Presence (verbatim settings from init.lua)
      require("presence").setup({
        auto_update = true,
        neovim_image_text = "The One True Text Editor",
        main_image = "neovim",
        client_id = "793271441293967371",
        log_level = nil,
        debounce_timeout = 10,
        enable_line_number = false,
        blacklist = {},
        buttons = true,
        file_assets = {},
        show_time = true,
        editing_text = "Editing %s",
        file_explorer_text = "Browsing %s",
        git_commit_text = "Committing changes",
        plugin_manager_text = "Managing plugins",
        reading_text = "Reading %s",
        workspace_text = "Working on %s",
        line_number_text = "Line %s out of %s",
      })

      -- vim-dadbod-ui connections (verbatim from ownaddons.lua)
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.dbs = {
        {
          name = "Oracle Class",
          url = "oracle://C##FOURNIEO:Lycia@205.237.244.252:1521/ORCL",
        },
      }
    '';

    # ================== EDITOR CORE ==================
    plugins = {
      # which-key — verbatim LazyVim spec via __raw (translation-safe)
      which-key = {
        enable = true;
        settings = {
          preset = "modern";
          spec.__raw = ''
            {
              {
                mode = { "n", "x" },
                { "<leader><tab>", group = "tabs" },
                { "<leader>c", group = "code" },
                { "<leader>d", group = "debug" },
                { "<leader>dp", group = "profiler" },
                { "<leader>f", group = "file/find" },
                { "<leader>g", group = "git" },
                { "<leader>gh", group = "hunks" },
                { "<leader>q", group = "quit/session" },
                { "<leader>s", group = "search" },
                { "<leader>u", group = "ui" },
                { "<leader>x", group = "diagnostics/quickfix" },
                { "[", group = "prev" },
                { "]", group = "next" },
                { "g", group = "goto" },
                { "gs", group = "surround" },
                { "z", group = "fold" },
                { "gx", desc = "Open with system app" },
              },
            }
          '';
        };
      };
      lualine.enable = true;
      bufferline.enable = true;
      noice.enable = true;
      gitsigns.enable = true;
      todo-comments.enable = true;
      persistence.enable = true; # session restore
      flash.enable = true; # jump/motion plugin (LazyVim default)
      yanky.enable = true; # better yank/paste history
      trouble.enable = true; # diagnostics list
      render-markdown.enable = true; # lang.markdown
      indent-blankline.enable = true; # ui.indent-blankline
      lazydev.enable = true; # lua dev for config editing

      # snacks: picker/explorer/dashboard — verbatim LazyVim dashboard via __raw
      snacks = {
        enable = true;
        settings.dashboard.__raw = ''
          {
            preset = {
              header = [[
              ██╗      █████╗ ███████╗██╗   ██╗██╗   ██╗██╗███╗   ███╗          Z
              ██║     ██╔══██╗╚══███╔╝╚██╗ ██╔╝██║   ██║██║████╗ ████║      Z
              ██║     ███████║  ███╔╝  ╚████╔╝ ██║   ██║██║██╔████╔██║   z
              ██║     ██╔══██║ ███╔╝    ╚██╔╝  ╚██╗ ██╔╝██║██║╚██╔╝██║ z
              ███████╗██║  ██║███████╗   ██║    ╚████╔╝ ██║██║ ╚═╝ ██║
              ╚══════╝╚═╝  ╚═╝╚══════╝   ╚═╝     ╚═══╝  ╚═╝╚═╝     ╚═╝
              ]],
              keys = {
                { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
                { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
                { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
                { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
                { icon = " ", key = "s", desc = "Restore Session", section = "session" },
                { icon = " ", key = "q", desc = "Quit", action = ":qa" },
              },
            },
            sections = {
              { section = "header" },
              { section = "keys", gap = 1, padding = 1 },
              { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
              { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
            },
          }
        '';
      };

      # mini.* family used by LazyVim
      mini = {
        enable = true;
        modules = {
          ai = { }; # enhanced text objects
          pairs = { }; # auto pairs
          icons = { }; # dev icons
          hipatterns = { }; # util.mini-hipatterns (hex colors etc)
        };
      };

      # ================== COMPLETION (coding.blink) ==================
      blink-cmp = {
        enable = true;
        settings = {
          sources = {
            default = [ "lsp" "path" "snippets" "buffer" ];
          };
        };
      };

      # ================== AI ==================
      # copilot-lua/copilot-chat DISABLED: vimplugin-copilot.lua hard-requires the
      # unfree copilot-language-server inside nixpkgs' plugin packaging (postInstall
      # shim) — no allowUnfree path reaches it. Re-add as extraPlugin when wanted.
      # ai.sidekick → extraPlugins (module too new; see maybeSidekick)

      # ================== TREESITTER ==================
      treesitter = {
        enable = true;
        settings = {
          highlight.enable = true;
          indent = true;
        };
      };
      ts-autotag.enable = true; # HTML/JSX tag auto-close

      # ================== LSP (mason → nixpkgs, servers from packages.nix) ==================
      lsp = {
        enable = true;
        keymaps = {
          diagnostic = {
            "<leader>cd" = "open_float";
            "[d" = "goto_prev";
            "]d" = "goto_next";
          };
          lspBuf = {
            "gd" = "definition";
            "gr" = "references";
            "K" = "hover"; # NOTE: colemak K = search-prev; hover wins here as in LazyVim
            "<leader>ca" = "code_action";
            "<leader>cr" = "rename";
          };
        };
        servers = {
          clangd.enable = true; # lang.clangd (C/K&R/CS:APP)
          cmake.enable = true; # lang.cmake
          gopls.enable = true; # lang.go
          jsonls.enable = true; # lang.json (+SchemaStore below)
          yamlls.enable = true; # lang.yaml
          html.enable = true; # web
          cssls.enable = true; # web
          dockerls.enable = true; # lang.docker
          docker_compose_language_service.enable = true;
          taplo.enable = true; # lang.toml
          marksman.enable = true; # lang.markdown
          nil_ls.enable = true; # lang.nix
          zls.enable = true; # lang.zig
          ts_ls.enable = true; # lang.typescript
          vtsls.enable = true; # lang.typescript (LazyVim uses vtsls)
          intelephense.enable = false; # unfree LSP; PHP not in rotation — re-enable if ever needed
          pyright.enable = true; # python (was mason-era; explicit now)
          # C#/.NET 10: OmniSharp 1.39 is deprecated + stuck on old Roslyn — cannot load
          # .NET 10 / C# 14 solutions. Replaced by Roslyn LS via roslyn-nvim (below).
          omnisharp.enable = false;
          # typst LSP: nixvim main now ships tinymist under lsp.servers.tinymist;
          # if missing in this nixpkgs pin, it is provided via typst-preview-nvim plugin instead
          # sqlls dropped from nixpkgs — enable with null pkg (uses PATH) or re-enable when back
          sqlls = {
            enable = true;
            package = null;
          }; # lang.sql
          # rust via rustaceanvim below (lang.rust)
          copilot.package = null; # unfree copilot-language-server — node shim on PATH instead
        };
      };

      # Roslyn LS — the Microsoft-blessed successor to OmniSharp, tracks current
      # .NET (nixpkgs 5.11.0-1.26380.x builds against .NET 10) → C# 14 capable.
      # Attached via the roslyn-nvim plugin, not lspconfig's deprecated path.
      roslyn = {
        enable = true;
        settings = {
          cmd = [
            "${pkgs.roslyn-ls}/bin/Microsoft.CodeAnalysis.LanguageServer"
            "--logLevel=Information"
            "--extensionLogDirectory=/tmp/roslyn/logs"
          ];
          settings = {
            RoslynExtensions = {
              enableAnalyzers = true;
              enableDecompilationSupport = true;
            };
          };
        };
      };

      rustaceanvim.enable = true; # lang.rust (fatter than rust-analyzer lsp alone)
      jdtls.enable = true; # lang.java
      neoconf.enable = true; # lsp.neoconf

      # ================== FORMATTING / LINTING ==================
      conform-nvim = {
        enable = true;
        settings = {
          formatters_by_ft = {
            # formatting.prettier (web)
            javascript = [ "prettier" ];
            typescript = [ "prettier" ];
            javascriptreact = [ "prettier" ];
            typescriptreact = [ "prettier" ];
            css = [ "prettier" ];
            html = [ "prettier" ];
            json = [ "prettier" ];
            yaml = [ "prettier" ];
            markdown = [ "prettier" ];
            # formatting.black (python)
            python = [ "black" ];
            # C# via csharpier (.NET 10 ready)
            cs = [ "csharpier" ];
            cshtml = [ "csharpier" ];
            # sql: sql-formatter was dropped from nixpkgs — re-add when available
          };
        };
      };

      lint = {
        enable = true; # linting.eslint via nvim-lint
        lintersByFt = {
          javascript = [ "eslint" ];
          typescript = [ "eslint" ];
          javascriptreact = [ "eslint" ];
          typescriptreact = [ "eslint" ];
        };
      };

      # ================== DAP (dap.core + nlua + dotnet/go) ==================
      dap = {
        enable = true;
        adapters.executables = {
          # delve + netcoredbg already in packages.nix
          # NOTE: codellld for C not in packages.nix — add there if needed
        };
      };
      dap-ui.enable = true;
      dap-virtual-text.enable = true;

      # ================== TEST (test.core) ==================
      neotest = {
        enable = true;
        # adapters (go/dotnet/php/zig) via extraPlugins if you use them
      };

      # ================== MISC EDITOR EXTRAS ==================
      inc-rename.enable = true; # editor.inc-rename
      refactoring.enable = true; # editor.refactoring
      neogen.enable = true; # coding.neogen (doc comments)
      aerial.enable = true; # editor.outline (symbol tree; nixvim calls it aerial)
      overseer.enable = true; # editor.overseer (task runner)
      grug-far.enable = true; # find/replace
      dial.enable = true; # editor.dial (increment dates etc)

      # ================== OTTER (quarto-style, JS/CSS in HTML) ==================
      # config + <leader>oa keymap declared in keymaps + extraConfigLua
    };

    # plugins without stable nixvim modules
    extraPlugins = with pkgs.vimPlugins; [
      otter-nvim
      vim-dadbod
      vim-dadbod-ui
      vim-dadbod-completion
      presence-nvim
      ts-comments-nvim
      markdown-preview-nvim
      typst-preview-nvim
    ];
    # NOTE: sidekick.nvim (ai.sidekick extra) has no nixpkgs package yet
    # (Aug 2026). When vimPlugins.sidekick-nvim lands, add it above.
    # Vendoring it via buildVimPlugin needs a pinned rev+hash — do it then.

    # tools the plugins shell out to
    extraPackages = with pkgs; [
      prettier # formatting.prettier (top-level since nodePackages removal)
      black # formatting.black (top-level pkg — python311 pin pulls sphinx9/py311 breakage)
      # sql-formatter: dropped from nixpkgs (nodePackages removal) — Oracle SQL formatting via prettier or re-add later
      eslint # nvim-lint eslint (top-level)
      csharpier # C# formatter (dotnet tool style, .NET 10 compatible)
    ];
  };
  };
}
