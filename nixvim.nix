# =====================================================================
# Nixvim — Dyna's Colemak-DH Catppuccin Mocha Neovim Workbench
# =====================================================================
# Activation: `dyna.nixvim.enable = true` in home.nix / home-wsl.nix.
#
# Colemak-DH Layout Philosophy (100% consistent across ALL modes & plugins):
#   Directional:  n=Left, e=Down, i=Up, o=Right  (Normal, Visual, Operator)
#   Displaced:    l/L=Insert (and `l` = inner text-object: clw, dl(, vlw)
#                 h/H=Open line below/above (visual: swap selection end)
#                 j/J=End of word/WORD    k/K=Search next/prev
#                 gJ=Join lines           gl=Insert at last position
#   Windows:      <C-n/e/i/o> and <C-w>n/e/i/o   |  Jumplist: [j / ]j
#   Buffers:      <S-n> / <S-o> (prev/next)      |  <leader>bd (delete)
#   Move lines:   <A-e> / <A-i> (down/up)
# =====================================================================
{ config, lib, pkgs, ... }:

let
  cfg = config.dyna.nixvim;

  # Pass 2 of C# formatting: attach K&R same-line braces after csharpier.
  # Packaged in Nix so it survives every flake update on laptop/desktop/WSL.
  csBraceAttach = pkgs.writeShellScriptBin "cs-brace-attach" ''
    set -euo pipefail
    exec ${pkgs.clang-tools}/bin/clang-format \
      --assume-filename=file.cs \
      --style='{BasedOnStyle: LLVM, IndentWidth: 4, BreakBeforeBraces: Attach, ColumnLimit: 100, BreakBeforeBinaryOperators: All, AlignOperands: Align, FixNamespaceComments: false, AccessModifierOffset: -4, IndentCaseLabels: false, AllowShortFunctionsOnASingleLine: None, AllowShortIfStatementsOnASingleLine: false, Language: CSharp}'
  '';

  # Wrapper for Roslyn LS: strips --daemon-mode (nvim 0.12's lsp/roslyn.lua
  # passes it, which nixpkgs roslyn-ls rejects).
  roslynWrapper = pkgs.writeShellScriptBin "roslyn-language-server" ''
    args=()
    for a in "$@"; do
      [ "$a" = "--daemon-mode" ] && continue
      args+=("$a")
    done
    exec ${pkgs.roslyn-ls}/bin/Microsoft.CodeAnalysis.LanguageServer "''${args[@]}"
  '';
in
{
  options.dyna.nixvim = {
    enable = lib.mkEnableOption "Nixvim editor (Colemak-DH workbench)";
  };

  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      enable = true;

      # ================== OPTIONS / GLOBALS ==================
      globals = {
        mapleader = " ";
        maplocalleader = " ";
        format_on_save = true;
      };

      colorschemes.catppuccin = {
        enable = true;
        settings = {
          flavour = "mocha";
          integrations = {
            blink_cmp = true;
            flash = true;
            gitsigns = true;
            grug_far = true;
            mini.enabled = true;
            noice = true;
            snacks = true;
            treesitter = true;
            lsp_trouble = true;
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
        splitbelow = true;
        splitright = true;
        showmode = false;
        wrap = false;
        mouse = "a";
        scrolloff = 8;
        sidescrolloff = 8;
        confirm = true;
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

      # ================== KEYMAPS (COLEMAK-DH, CONSISTENT) ==================
      keymaps = [
        # --- Directional (n/e/i/o = Left/Down/Up/Right in ALL modes) ---
        { mode = [ "n" "x" "o" ]; key = "n"; action = "h"; options.desc = "Left"; }
        { mode = [ "n" "x" ]; key = "e"; action = "gj"; options.desc = "Down"; }
        { mode = "o"; key = "e"; action = "j"; options.desc = "Down"; }
        { mode = [ "n" "x" ]; key = "i"; action = "gk"; options.desc = "Up"; }
        { mode = "o"; key = "i"; action = "k"; options.desc = "Up"; }
        { mode = [ "n" "x" "o" ]; key = "o"; action = "l"; options.desc = "Right"; }

        # --- Displaced builtins ---
        # l/L = Insert (Normal) & inner text-object prefix (Visual/Operator: clw, dl(, vlw)
        { mode = "n"; key = "l"; action = "i"; options.desc = "Insert"; }
        { mode = [ "n" "x" ]; key = "L"; action = "I"; options.desc = "Insert at line start"; }
        { mode = [ "x" "o" ]; key = "l"; action = "i"; options.desc = "Inner text object"; }
        { mode = "n"; key = "gl"; action = "gi"; options.desc = "Insert at last position"; }

        # h/H = Open line (Normal) / swap selection end (Visual)
        { mode = "n"; key = "h"; action = "o"; options.desc = "Open line below"; }
        { mode = "n"; key = "H"; action = "O"; options.desc = "Open line above"; }
        { mode = "x"; key = "h"; action = "o"; options.desc = "Other end of selection"; }
        { mode = "x"; key = "H"; action = "O"; options.desc = "Other corner of selection"; }

        # j/J = End of word/WORD, gJ = Join lines
        { mode = [ "n" "x" "o" ]; key = "j"; action = "e"; options.desc = "End of word"; }
        { mode = [ "n" "x" "o" ]; key = "J"; action = "E"; options.desc = "End of WORD"; }
        { mode = [ "n" "x" ]; key = "gJ"; action = "J"; options.desc = "Join lines"; }

        # k/K = Search next/prev (centered)
        { mode = [ "n" "x" "o" ]; key = "k"; action = "n"; options.desc = "Search next"; }
        { mode = [ "n" "x" "o" ]; key = "K"; action = "N"; options.desc = "Search previous"; }

        # --- Window navigation (Ctrl + n/e/i/o AND <C-w> + n/e/i/o) ---
        { mode = "n"; key = "<C-n>"; action = "<C-w>h"; options.desc = "Window left"; }
        { mode = "n"; key = "<C-e>"; action = "<C-w>j"; options.desc = "Window down"; }
        { mode = "n"; key = "<C-i>"; action = "<C-w>k"; options.desc = "Window up"; }
        { mode = "n"; key = "<C-o>"; action = "<C-w>l"; options.desc = "Window right"; }
        { mode = "n"; key = "<C-w>n"; action = "<C-w>h"; options.desc = "Window left"; }
        { mode = "n"; key = "<C-w>e"; action = "<C-w>j"; options.desc = "Window down"; }
        { mode = "n"; key = "<C-w>i"; action = "<C-w>k"; options.desc = "Window up"; }
        { mode = "n"; key = "<C-w>o"; action = "<C-w>l"; options.desc = "Window right"; }
        { mode = "n"; key = "<C-w>N"; action = "<C-w>H"; options.desc = "Move window left"; }
        { mode = "n"; key = "<C-w>E"; action = "<C-w>J"; options.desc = "Move window down"; }
        { mode = "n"; key = "<C-w>I"; action = "<C-w>K"; options.desc = "Move window up"; }
        { mode = "n"; key = "<C-w>O"; action = "<C-w>L"; options.desc = "Move window right"; }

        # Jumplist (since <C-o>/<C-i> are window nav)
        { mode = "n"; key = "[j"; action = "<C-o>"; options.desc = "Jump back"; }
        { mode = "n"; key = "]j"; action = "<C-i>"; options.desc = "Jump forward"; }

        # --- Buffers ---
        { mode = "n"; key = "<S-n>"; action = "<cmd>bprevious<cr>"; options.desc = "Prev buffer"; }
        { mode = "n"; key = "<S-o>"; action = "<cmd>bnext<cr>"; options.desc = "Next buffer"; }
        { mode = "n"; key = "<leader>bd"; action.__raw = "function() require('snacks').bufdelete() end"; options.desc = "Delete Buffer"; }

        # --- Move lines (Alt + e/i) & editing quality-of-life ---
        { mode = "n"; key = "<A-e>"; action = "<cmd>execute 'move .+' . v:count1<cr>=="; options.desc = "Move line down"; }
        { mode = "n"; key = "<A-i>"; action = "<cmd>execute 'move .-' . (v:count1 + 1)<cr>=="; options.desc = "Move line up"; }
        { mode = "i"; key = "<A-e>"; action = "<esc><cmd>m .+1<cr>==gi"; options.desc = "Move line down"; }
        { mode = "i"; key = "<A-i>"; action = "<esc><cmd>m .-2<cr>==gi"; options.desc = "Move line up"; }
        { mode = "v"; key = "<A-e>"; action = ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv"; options.desc = "Move selection down"; }
        { mode = "v"; key = "<A-i>"; action = ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv"; options.desc = "Move selection up"; }
        { mode = "x"; key = "<"; action = "<gv"; options.desc = "Indent left"; }
        { mode = "x"; key = ">"; action = ">gv"; options.desc = "Indent right"; }
        { mode = "n"; key = "<Esc>"; action = "<cmd>nohlsearch<cr>"; options.desc = "Clear search highlight"; }

        # --- Flash jump ---
        { mode = [ "n" "x" "o" ]; key = "s"; action.__raw = "function() require('flash').jump() end"; options.desc = "Flash Jump"; }
        { mode = [ "n" "x" "o" ]; key = "S"; action.__raw = "function() require('flash').treesitter() end"; options.desc = "Flash Treesitter"; }
        { mode = "o"; key = "r"; action.__raw = "function() require('flash').remote() end"; options.desc = "Remote Flash"; }

        # --- Snacks Picker / Explorer / Lazygit / Terminal ---
        { mode = "n"; key = "<leader><leader>"; action.__raw = "function() require('snacks').picker.smart() end"; options.desc = "Smart Find Files"; }
        { mode = "n"; key = "<leader>/"; action.__raw = "function() require('snacks').picker.grep() end"; options.desc = "Grep"; }
        { mode = "n"; key = "<leader>e"; action.__raw = "function() require('snacks').explorer() end"; options.desc = "File Explorer"; }
        { mode = "n"; key = "<leader>,"; action.__raw = "function() require('snacks').picker.buffers() end"; options.desc = "Buffers"; }
        { mode = "n"; key = "<leader>ff"; action.__raw = "function() require('snacks').picker.files() end"; options.desc = "Find Files"; }
        { mode = "n"; key = "<leader>fr"; action.__raw = "function() require('snacks').picker.recent() end"; options.desc = "Recent Files"; }
        { mode = "n"; key = "<leader>fb"; action.__raw = "function() require('snacks').picker.buffers() end"; options.desc = "Buffers"; }
        { mode = "n"; key = "<leader>fm"; action.__raw = "function() require('snacks').picker.marks() end"; options.desc = "Marks"; }
        { mode = "n"; key = "<leader>fg"; action.__raw = "function() require('snacks').picker.git_files() end"; options.desc = "Git Files"; }
        { mode = "n"; key = "<leader>gg"; action.__raw = "function() require('snacks').lazygit() end"; options.desc = "Lazygit"; }
        { mode = "n"; key = "<leader>ft"; action.__raw = "function() require('snacks').terminal() end"; options.desc = "Terminal"; }
        { mode = "t"; key = "<C-/>"; action.__raw = "function() require('snacks').terminal() end"; options.desc = "Toggle Terminal"; }

        # --- Search & Replace ---
        { mode = "n"; key = "<leader>ss"; action.__raw = "function() require('snacks').picker.lsp_symbols() end"; options.desc = "Goto Symbol"; }
        { mode = "n"; key = "<leader>sw"; action.__raw = "function() require('snacks').picker.grep_word() end"; options.desc = "Grep Word"; }
        { mode = "n"; key = "<leader>sk"; action.__raw = "function() require('snacks').picker.keymaps() end"; options.desc = "Keymaps"; }
        { mode = [ "n" "v" ]; key = "<leader>sr"; action.__raw = "function() require('grug-far').open() end"; options.desc = "Search & Replace (Grug-Far)"; }

        # --- Code / Format / Outline / Otter ---
        { mode = "n"; key = "<leader>cf"; action.__raw = "function() require('conform').format({ async = true, lsp_format = 'fallback' }) end"; options.desc = "Format Buffer"; }
        { mode = "v"; key = "<leader>cf"; action.__raw = "function() require('conform').format({ async = true, lsp_format = 'fallback', range = true }) end"; options.desc = "Format Range"; }
        { mode = "n"; key = "<leader>cs"; action = "<cmd>AerialToggle!<cr>"; options.desc = "Symbols Outline (Aerial)"; }
        { mode = "n"; key = "<leader>oa"; action.__raw = "function() require('otter').activate({'javascript','css'}, true, true, nil) end"; options.desc = "Otter Activate (JS/CSS in HTML)"; }

        # --- Debugger (DAP) ---
        { mode = "n"; key = "<leader>db"; action.__raw = "function() require('dap').toggle_breakpoint() end"; options.desc = "Toggle Breakpoint"; }
        { mode = "n"; key = "<leader>dB"; action.__raw = "function() require('dap').set_breakpoint(vim.fn.input('Condition: ')) end"; options.desc = "Conditional Breakpoint"; }
        { mode = "n"; key = "<leader>dc"; action.__raw = "function() require('dap').continue() end"; options.desc = "Continue/Start"; }
        { mode = "n"; key = "<leader>do"; action.__raw = "function() require('dap').step_over() end"; options.desc = "Step Over"; }
        { mode = "n"; key = "<leader>di"; action.__raw = "function() require('dap').step_into() end"; options.desc = "Step Into"; }
        { mode = "n"; key = "<leader>dt"; action.__raw = "function() require('dap').terminate() end"; options.desc = "Terminate"; }
        { mode = "n"; key = "<leader>du"; action.__raw = "function() require('dapui').toggle() end"; options.desc = "Toggle DAP UI"; }
        { mode = [ "n" "v" ]; key = "<leader>de"; action.__raw = "function() require('dapui').eval() end"; options.desc = "Evaluate"; }

        # --- Diagnostics (Trouble) ---
        { mode = "n"; key = "<leader>xx"; action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>"; options.desc = "Diagnostics (Buffer)"; }
        { mode = "n"; key = "<leader>xX"; action = "<cmd>Trouble diagnostics toggle<cr>"; options.desc = "Diagnostics (Workspace)"; }
        { mode = "n"; key = "<leader>xq"; action = "<cmd>Trouble qflist toggle<cr>"; options.desc = "Quickfix (Trouble)"; }

        # --- Sessions ---
        { mode = "n"; key = "<leader>qs"; action.__raw = "function() require('persistence').load() end"; options.desc = "Restore Session"; }
        { mode = "n"; key = "<leader>qS"; action.__raw = "function() require('persistence').select() end"; options.desc = "Select Session"; }
        { mode = "n"; key = "<leader>ql"; action.__raw = "function() require('persistence').load({ last = true }) end"; options.desc = "Restore Last Session"; }

        # --- Windows ---
        { mode = "n"; key = "<leader>w-"; action = "<C-w>s"; options.desc = "Split below"; }
        { mode = "n"; key = "<leader>w\\"; action = "<C-w>v"; options.desc = "Split right"; }
        { mode = "n"; key = "<leader>wd"; action = "<C-w>c"; options.desc = "Close window"; }

        # --- UI Toggles ---
        { mode = "n"; key = "<leader>uf"; action.__raw = "function() vim.g.format_on_save = not (vim.g.format_on_save ~= false); vim.notify('Format on save: ' .. (vim.g.format_on_save and 'ON' or 'OFF')) end"; options.desc = "Toggle Format on Save"; }
        { mode = "n"; key = "<leader>uh"; action = "<cmd>Hardtime toggle<cr>"; options.desc = "Toggle Hardtime"; }
        { mode = "n"; key = "<leader>un"; action = "<cmd>set number!<cr>"; options.desc = "Toggle Line Numbers"; }
        { mode = "n"; key = "<leader>uw"; action = "<cmd>set wrap!<cr>"; options.desc = "Toggle Wrap"; }
        { mode = "n"; key = "<leader>us"; action = "<cmd>set spell!<cr>"; options.desc = "Toggle Spell"; }
      ];

      # ================== AUTOCMDS ==================
      autoCmd = [
        {
          event = [ "TermOpen" ];
          pattern = [ "*" ];
          command = "startinsert";
        }
        {
          event = [ "TextYankPost" ];
          pattern = [ "*" ];
          callback.__raw = "function() vim.hl.on_yank({ timeout = 150 }) end";
        }
      ];

      # ================== PERSONAL COMMANDS & PLUGIN HOOKS ==================
      extraConfigLua = ''
        -- Mock nvim-web-devicons via mini.icons (single icon source)
        pcall(function() require("mini.icons").mock_nvim_web_devicons() end)

        -- :Crun for K&R and CS:APP single-file C exercises
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

        -- :Csrun for quick single-file .NET 10 runs
        vim.api.nvim_create_user_command("Csrun", function()
          local file = vim.fn.expand("%:p")
          vim.cmd("write")
          vim.cmd("vsplit")
          vim.cmd.terminal("dotnet run " .. vim.fn.shellescape(file))
          vim.cmd("startinsert")
        end, { desc = "Run .NET file" })

        -- :CSdebug — build .NET project (or loose file) & launch netcoredbg
        vim.api.nvim_create_user_command("CSdebug", function()
          local file = vim.fn.expand("%:p")
          if file == "" then
            return vim.notify("CSdebug: no file in buffer", vim.log.levels.WARN)
          end
          vim.cmd("write")

          local srcdir = vim.fn.fnamemodify(file, ":h")
          local proj = vim.fs.find(function(name) return name:match("%.csproj$") end, { upward = true, path = srcdir })[1]
          local sln = proj and nil
            or vim.fs.find(function(name) return name:match("%.slnx?$") end, { upward = true, path = srcdir })[1]

          local target, cwd, name
          if proj then
            target, cwd, name = proj, vim.fn.fnamemodify(proj, ":h"), vim.fn.fnamemodify(proj, ":t:r")
          elseif sln then
            target, cwd, name = sln, vim.fn.fnamemodify(sln, ":h"), vim.fn.fnamemodify(sln, ":t:r")
          else
            name = vim.fn.fnamemodify(file, ":t:r")
            local tmp = vim.fn.stdpath("cache") .. "/csdebug/" .. name
            vim.fn.mkdir(tmp, "p")
            local includes = {}
            for _, n in ipairs(vim.fn.glob(srcdir .. "/*.cs", false, true)) do
              local base = vim.fn.fnamemodify(n, ":t")
              table.insert(includes, '    <Compile Include="' .. n .. '" Link="' .. base .. '" />')
            end
            vim.fn.writefile({
              '<Project Sdk="Microsoft.NET.Sdk">',
              '  <PropertyGroup>',
              '    <OutputType>Exe</OutputType>',
              '    <TargetFramework>net10.0</TargetFramework>',
              '    <ImplicitUsings>enable</ImplicitUsings>',
              '    <Nullable>enable</Nullable>',
              '    <AssemblyName>' .. name .. '</AssemblyName>',
              '  </PropertyGroup>',
              '  <ItemGroup>',
              table.concat(includes, "\n"),
              '  </ItemGroup>',
              '</Project>',
            }, tmp .. "/" .. name .. ".csproj")
            target, cwd = tmp .. "/" .. name .. ".csproj", srcdir
          end

          vim.notify("CSdebug: building " .. vim.fn.fnamemodify(target, ":t") .. "…")
          local out = vim.fn.system({ "dotnet", "build", target, "--nologo", "-v", "q" })
          if vim.v.shell_error ~= 0 then
            vim.notify("CSdebug: build FAILED", vim.log.levels.ERROR)
            vim.cmd("vnew")
            vim.api.nvim_buf_set_lines(0, 0, -1, false, vim.fn.split(out, "\n"))
            return
          end

          local dll = nil
          for line in out:gmatch("[^\r\n]+") do
            local m = line:match("%->%s*(%S+%.dll)")
            if m then dll = m end
          end
          if not dll or vim.fn.filereadable(dll) == 0 then
            local hits = vim.fn.glob(vim.fn.fnamemodify(target, ":h") .. "/bin/Debug/**/" .. name .. ".dll", false, true)
            dll = hits[1]
          end
          if not dll then
            return vim.notify("CSdebug: no DLL found after build", vim.log.levels.ERROR)
          end

          vim.notify("CSdebug: debugging " .. dll)
          require("dap").run({
            type = "coreclr",
            request = "launch",
            name = "CSdebug " .. vim.fn.fnamemodify(dll, ":t:r"),
            program = dll,
            cwd = cwd,
          })
          pcall(function() require("dapui").open() end)
        end, { desc = "Build & debug .NET (project or loose file)" })

        -- HTML '!' template (triggers only on empty line start)
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
    <footer></footer>
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

        -- Discord Rich Presence (guarded so SSH/WSL/no-Discord never errors)
        pcall(function()
          require("presence").setup({
            auto_update = true,
            neovim_image_text = "The One True Text Editor",
            main_image = "neovim",
            client_id = "793271441293967371",
            debounce_timeout = 10,
            buttons = true,
            show_time = true,
          })
        end)

        -- vim-dadbod-ui connections
        vim.g.db_ui_use_nerd_fonts = 1
        vim.g.dbs = {
          {
            name = "Oracle Class",
            url = "oracle://C##FOURNIEO:Lycia@205.237.244.252:1521/ORCL",
          },
        }

        -- hardtime.nvim — Colemak-DH native (toggle anytime with <leader>uh)
        pcall(function()
          require("hardtime").setup({
            disabled_filetypes = {
              "qf", "help", "Trouble", "trouble", "aerial", "grug-far",
              "snacks_dashboard", "snacks_picker_list", "snacks_picker_input",
              "snacks_terminal", "dapui_scopes", "dapui_breakpoints",
              "dapui_stacks", "dapui_watches", "dap-repl", "dbui",
            },
            restricted_keys = {
              ["n"] = { "n", "x" },
              ["e"] = { "n", "x" },
              ["i"] = { "n", "x" },
              ["o"] = { "n", "x" },
              ["+"] = { "n", "x" },
              ["gj"] = { "n", "x" },
              ["gk"] = { "n", "x" },
              ["h"] = {},
              ["j"] = {},
              ["k"] = {},
              ["l"] = {},
            },
            disabled_keys = {
              ["<Up>"] = { "", "i" },
              ["<Down>"] = { "", "i" },
              ["<Left>"] = { "", "i" },
              ["<Right>"] = { "", "i" },
            },
            hints = {
              ["%^l"] = { message = function() return "Use L instead of ^l" end, length = 2 },
              ["[^fFtT]ol"] = { message = function() return "Use a instead of ol" end, length = 3 },
              ["%$a"] = { message = function() return "Use A instead of $a" end, length = 2 },
              ["d%$"] = { message = function() return "Use D instead of d$" end, length = 2 },
              ["y%$"] = { message = function() return "Use Y instead of y$" end, length = 2 },
              ["c%$"] = { message = function() return "Use C instead of c$" end, length = 2 },
              ["D[aA]"] = { message = function(k) return "Use C instead of D" .. k:sub(2) end, length = 2 },
            },
          })
        end)
      '';

      # ================== EDITOR PLUGINS ==================
      plugins = {
        which-key = {
          enable = true;
          settings = {
            preset = "modern";
            spec.__raw = ''
              {
                {
                  mode = { "n", "x" },
                  { "<leader>b", group = "buffer" },
                  { "<leader>c", group = "code" },
                  { "<leader>d", group = "debug" },
                  { "<leader>f", group = "file/find" },
                  { "<leader>g", group = "git" },
                  { "<leader>o", group = "otter" },
                  { "<leader>q", group = "session" },
                  { "<leader>s", group = "search" },
                  { "<leader>u", group = "ui toggles" },
                  { "<leader>w", group = "windows" },
                  { "<leader>x", group = "diagnostics" },
                  { "[", group = "prev" },
                  { "]", group = "next" },
                  { "g", group = "goto" },
                  { "gs", group = "surround" },
                  { "z", group = "fold" },
                },
              }
            '';
          };
        };

        lualine = {
          enable = true;
          settings.options = {
            globalstatus = true;
            icons_enabled = true;
            theme = "catppuccin";
          };
        };

        bufferline.enable = true;
        noice.enable = true;
        gitsigns.enable = true;
        todo-comments.enable = true;
        persistence.enable = true;
        render-markdown.enable = true;
        indent-blankline.enable = true;
        lazydev.enable = true;
        inc-rename.enable = true;

        # Flash with Colemak-DH home-row jump labels
        flash = {
          enable = true;
          settings = {
            labels = "arstgmneioqwfpbjluyzxcdvkh";
          };
        };

        # Trouble with Colemak-DH navigation
        trouble = {
          enable = true;
          settings.keys = {
            e = "next";
            i = "prev";
            o = "jump";
            n = "fold_close";
          };
        };

        # Aerial (symbol outline) with Colemak-DH navigation
        aerial = {
          enable = true;
          settings.keymaps = {
            e = "actions.down_and_scroll";
            i = "actions.up_and_scroll";
            o = "actions.jump";
            n = "actions.tree_close";
          };
        };

        grug-far.enable = true;

        leetcode = {
          enable = true;
          settings = {
            lang = "csharp";
            storage.home = "~/projects/leetcode";
          };
        };

        # Snacks: picker, explorer, dashboard, lazygit, terminal — Colemak-DH native
        snacks = {
          enable = true;
          settings = {
            bufdelete.enabled = true;
            explorer.enabled = true;
            lazygit.enabled = true;
            terminal.enabled = true;
            picker = {
              enabled = true;
              sources.files.exclude = [ "bin" "obj" "*.bak-*" ];
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
                  ]],
                  keys = {
                    { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.dashboard.pick('files')" },
                    { icon = " ", key = "c", desc = "New File", action = ":ene | startinsert" },
                    { icon = " ", key = "g", desc = "Grep Text", action = ":lua Snacks.dashboard.pick('live_grep')" },
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
        };

        # mini.* — with Colemak-DH `l` inner text-objects + real `gs` surround
        mini = {
          enable = true;
          modules = {
            ai = {
              mappings = {
                around = "a";
                inside = "l";
                around_next = "an";
                inside_next = "ln";
                around_last = "ap";
                inside_last = "lp";
              };
            };
            surround = {
              mappings = {
                add = "gsa";
                delete = "gsd";
                find = "gsf";
                find_left = "gsF";
                highlight = "gsh";
                replace = "gsr";
                update_n_lines = "gsn";
              };
            };
            pairs = { };
            icons = { };
            hipatterns = { };
          };
        };

        # ================== COMPLETION (blink-cmp, Colemak-DH nav) ==================
        blink-cmp = {
          enable = true;
          settings = {
            sources.default = [ "lsp" "path" "snippets" "buffer" ];
            keymap = {
              preset = "default";
              "<C-e>" = [ "select_next" "fallback" ];
              "<C-i>" = [ "select_prev" "fallback" ];
              "<Tab>" = [ "select_and_accept" "snippet_forward" "fallback" ];
              "<S-Tab>" = [ "select_prev" "snippet_backward" "fallback" ];
              "<CR>" = [ "accept" "fallback" ];
            };
          };
        };

        # ================== TREESITTER ==================
        treesitter = {
          enable = true;
          settings = {
            highlight.enable = true;
            indent.enable = true;
          };
        };
        ts-autotag.enable = true;

        # ================== LSP ==================
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
              "gD" = "declaration";
              "gr" = "references";
              "gI" = "implementation";
              "<leader>K" = "hover";
              "<leader>ca" = "code_action";
              "<leader>cr" = "rename";
            };
          };
          servers = {
            clangd.enable = true;
            cmake.enable = true;
            gopls.enable = true;
            jsonls.enable = true;
            yamlls.enable = true;
            html.enable = true;
            cssls.enable = true;
            dockerls.enable = true;
            docker_compose_language_service.enable = true;
            taplo.enable = true;
            marksman.enable = true;
            nil_ls.enable = true;
            zls.enable = true;
            vtsls.enable = true; # modern TS/JS LSP (duplicate ts_ls removed)
            pyright.enable = true;
            sqlls = {
              enable = true;
              package = null;
            };
          };
        };

        # Roslyn LS (C# 14 / .NET 10) via Nix wrapper stripping --daemon-mode
        roslyn = {
          enable = true;
          settings = {
            cmd = [
              "${roslynWrapper}/bin/roslyn-language-server"
              "--logLevel=Information"
              "--extensionLogDirectory=/tmp/roslyn/logs"
            ];
            settings.RoslynExtensions = {
              enableAnalyzers = true;
              enableDecompilationSupport = true;
            };
          };
        };

        rustaceanvim = {
          enable = true;
          settings.server.standalone = true;
        };
        jdtls.enable = true;

        # ================== FORMATTING / LINTING ==================
        conform-nvim = {
          enable = true;
          settings = {
            # Respects <leader>uf toggle cleanly
            format_on_save.__raw = ''
              function(bufnr)
                if vim.g.format_on_save == false then return end
                return { lsp_format = "fallback", timeout_ms = 3000 }
              end
            '';
            formatters_by_ft = {
              javascript = [ "prettier" ];
              typescript = [ "prettier" ];
              javascriptreact = [ "prettier" ];
              typescriptreact = [ "prettier" ];
              css = [ "prettier" ];
              html = [ "prettier" ];
              json = [ "prettier" ];
              yaml = [ "prettier" ];
              markdown = [ "prettier" ];
              python = [ "black" ];
              cs = [ "csharpier-stdin" "clang-format-cs" ];
              cshtml = [ "csharpier-stdin" "clang-format-cs" ];
              c = [ "clang-format" ];
              cpp = [ "clang-format" ];
              objc = [ "clang-format" ];
              cuda = [ "clang-format" ];
            };
            formatters = {
              csharpier-stdin = {
                command = "${pkgs.csharpier}/bin/csharpier";
                args = [ "format" "--stdin-path" "$FILENAME" ];
              };
              clang-format-cs = {
                command = "${csBraceAttach}/bin/cs-brace-attach";
                args = [ ];
              };
            };
          };
        };

        lint = {
          enable = true;
          lintersByFt = {
            javascript = [ "eslint" ];
            typescript = [ "eslint" ];
            javascriptreact = [ "eslint" ];
            typescriptreact = [ "eslint" ];
          };
        };

        # ================== DAP (.NET netcoredbg) ==================
        dap = {
          enable = true;
          adapters.executables.coreclr = {
            command = "${pkgs.netcoredbg}/bin/netcoredbg";
            args = [ "--interpreter=vscode" ];
          };
          configurations.cs = [
            {
              type = "coreclr";
              request = "launch";
              name = "Launch .NET";
              program.__raw = ''
                function()
                  local cwd = vim.fn.getcwd()
                  local name = vim.fn.fnamemodify(cwd, ":t")
                  local dlls = vim.fn.glob(cwd .. "/bin/Debug/**/*.dll", false, true)
                  for _, d in ipairs(dlls) do
                    if vim.fn.fnamemodify(d, ":t") == name .. ".dll" then return d end
                  end
                  if #dlls > 0 then return dlls[1] end
                  return vim.fn.input("Path to dll: ", cwd .. "/bin/Debug/", "file")
                end
              '';
            }
          ];
        };
        dap-ui.enable = true;
        dap-virtual-text.enable = true;
      };

      # ================== EXTRA PLUGINS & PACKAGES ==================
      extraPlugins = with pkgs.vimPlugins; [
        otter-nvim
        vim-dadbod
        vim-dadbod-ui
        vim-dadbod-completion
        presence-nvim
        ts-comments-nvim
        markdown-preview-nvim
        typst-preview-nvim
        hardtime-nvim
        nui-nvim
      ];

      extraPackages = with pkgs; [
        prettier
        black
        eslint
        csharpier
        clang-tools
        csBraceAttach
        roslynWrapper
      ];
    };
  };
}
