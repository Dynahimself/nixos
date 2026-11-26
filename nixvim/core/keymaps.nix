{ ... }:

{
  keymaps = [
    # Directional
    { mode = [ "n" "x" "o" ]; key = "n"; action = "h"; options.desc = "Left"; }
    { mode = [ "n" "x" ]; key = "e"; action = "gj"; options.desc = "Down"; }
    { mode = "o"; key = "e"; action = "j"; options.desc = "Down"; }
    { mode = [ "n" "x" ]; key = "i"; action = "gk"; options.desc = "Up"; }
    { mode = "o"; key = "i"; action = "k"; options.desc = "Up"; }
    { mode = [ "n" "x" "o" ]; key = "o"; action = "l"; options.desc = "Right"; }

    # Displaced builtins
    { mode = "n"; key = "l"; action = "i"; options.desc = "Insert"; }
    { mode = [ "n" "x" ]; key = "L"; action = "I"; options.desc = "Insert at line start"; }
    { mode = [ "x" "o" ]; key = "l"; action = "i"; options.desc = "Inner text object"; }
    { mode = "n"; key = "gl"; action = "gi"; options.desc = "Insert at last position"; }

    { mode = "n"; key = "h"; action = "o"; options.desc = "Open line below"; }
    { mode = "n"; key = "H"; action = "O"; options.desc = "Open line above"; }
    { mode = "x"; key = "h"; action = "o"; options.desc = "Other end of selection"; }
    { mode = "x"; key = "H"; action = "O"; options.desc = "Other corner of selection"; }

    { mode = [ "n" "x" "o" ]; key = "j"; action = "e"; options.desc = "End of word"; }
    { mode = [ "n" "x" "o" ]; key = "J"; action = "E"; options.desc = "End of WORD"; }
    { mode = [ "n" "x" ]; key = "gJ"; action = "J"; options.desc = "Join lines"; }

    # Search
    { mode = "n"; key = "k"; action = "nzzzv"; options.desc = "Search next (centered)"; }
    { mode = "n"; key = "K"; action = "Nzzzv"; options.desc = "Search prev (centered)"; }
    { mode = [ "x" "o" ]; key = "k"; action = "n"; options.desc = "Search next"; }
    { mode = [ "x" "o" ]; key = "K"; action = "N"; options.desc = "Search previous"; }
    { mode = "n"; key = "<C-d>"; action = "<C-d>zz"; options.desc = "Half-page down (centered)"; }
    { mode = "n"; key = "<C-u>"; action = "<C-u>zz"; options.desc = "Half-page up (centered)"; }

    # Window navigation
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

    # Jumplist
    { mode = "n"; key = "[j"; action = "<C-o>"; options.desc = "Jump back"; }
    { mode = "n"; key = "]j"; action = "<C-i>"; options.desc = "Jump forward"; }

    # Buffers
    { mode = "n"; key = "<S-n>"; action = "<cmd>BufferLineCyclePrev<cr>"; options.desc = "Prev buffer"; }
    { mode = "n"; key = "<S-o>"; action = "<cmd>BufferLineCycleNext<cr>"; options.desc = "Next buffer"; }
    { mode = "n"; key = "<leader>bd"; action.__raw = "function() require('snacks').bufdelete() end"; options.desc = "Delete Buffer"; }
    { mode = "n"; key = "<leader>bo"; action.__raw = "function() require('snacks').bufdelete.other() end"; options.desc = "Delete Other Buffers"; }
    { mode = "n"; key = "<leader>bp"; action = "<cmd>BufferLineTogglePin<cr>"; options.desc = "Pin Buffer"; }
    { mode = "n"; key = "<leader>bP"; action = "<cmd>BufferLineGroupClose ungrouped<cr>"; options.desc = "Close Non-Pinned Buffers"; }
    { mode = "n"; key = "<leader>bb"; action = "<cmd>BufferLinePick<cr>"; options.desc = "Pick Buffer"; }

    # Move lines
    { mode = "n"; key = "<A-e>"; action = "<cmd>execute 'move .+' . v:count1<cr>=="; options.desc = "Move line down"; }
    { mode = "n"; key = "<A-i>"; action = "<cmd>execute 'move .-' . (v:count1 + 1)<cr>=="; options.desc = "Move line up"; }
    { mode = "i"; key = "<A-e>"; action = "<esc><cmd>m .+1<cr>==gi"; options.desc = "Move line down"; }
    { mode = "i"; key = "<A-i>"; action = "<esc><cmd>m .-2<cr>==gi"; options.desc = "Move line up"; }
    { mode = "v"; key = "<A-e>"; action = ":<C-u>execute \"'<,'>move '>+\" . v:count1<cr>gv=gv"; options.desc = "Move selection down"; }
    { mode = "v"; key = "<A-i>"; action = ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<cr>gv=gv"; options.desc = "Move selection up"; }
    { mode = "x"; key = "<"; action = "<gv"; options.desc = "Indent left"; }
    { mode = "x"; key = ">"; action = ">gv"; options.desc = "Indent right"; }
    { mode = "n"; key = "<Esc>"; action = "<cmd>nohlsearch<cr>"; options.desc = "Clear search highlight"; }

    # Yanky
    { mode = [ "n" "x" ]; key = "p"; action = "<Plug>(YankyPutAfter)"; options.desc = "Put after (Yanky)"; }
    { mode = [ "n" "x" ]; key = "P"; action = "<Plug>(YankyPutBefore)"; options.desc = "Put before (Yanky)"; }
    { mode = "n"; key = "[y"; action = "<Plug>(YankyPreviousEntry)"; options.desc = "Prev Yank Entry"; }
    { mode = "n"; key = "]y"; action = "<Plug>(YankyNextEntry)"; options.desc = "Next Yank Entry"; }

    # Dial
    { mode = "n"; key = "<C-a>"; action.__raw = "function() require('dial.map').manipulate('increment', 'normal') end"; options.desc = "Smart Increment"; }
    { mode = "n"; key = "<C-x>"; action.__raw = "function() require('dial.map').manipulate('decrement', 'normal') end"; options.desc = "Smart Decrement"; }
    { mode = "v"; key = "<C-a>"; action.__raw = "function() require('dial.map').manipulate('increment', 'visual') end"; options.desc = "Smart Increment"; }
    { mode = "v"; key = "<C-x>"; action.__raw = "function() require('dial.map').manipulate('decrement', 'visual') end"; options.desc = "Smart Decrement"; }

    # Folding
    { mode = "n"; key = "zR"; action = "zR"; options.desc = "Open All Folds"; }
    { mode = "n"; key = "zM"; action = "zM"; options.desc = "Close All Folds"; }

    # Flash
    { mode = [ "n" "x" "o" ]; key = "s"; action.__raw = "function() require('flash').jump() end"; options.desc = "Flash Jump"; }
    { mode = [ "n" "x" "o" ]; key = "S"; action.__raw = "function() require('flash').treesitter() end"; options.desc = "Flash Treesitter"; }
    { mode = "o"; key = "r"; action.__raw = "function() require('flash').remote() end"; options.desc = "Remote Flash"; }

    # Oil
    { mode = "n"; key = "-"; action = "<cmd>Oil<cr>"; options.desc = "Oil Parent Dir"; }
    { mode = "n"; key = "<leader>-"; action.__raw = "function() require('oil').toggle_float() end"; options.desc = "Oil Float"; }

    # Dropbar
    { mode = "n"; key = "<leader>;"; action.__raw = "function() require('dropbar.api').pick() end"; options.desc = "Pick Breadcrumb"; }

    # Glance
    { mode = "n"; key = "gpd"; action = "<cmd>Glance definitions<cr>"; options.desc = "Peek Definitions"; }
    { mode = "n"; key = "gpr"; action = "<cmd>Glance references<cr>"; options.desc = "Peek References"; }
    { mode = "n"; key = "gpi"; action = "<cmd>Glance implementations<cr>"; options.desc = "Peek Implementations"; }
    { mode = "n"; key = "gpt"; action = "<cmd>Glance type_definitions<cr>"; options.desc = "Peek Type Definitions"; }

    # Snacks
    { mode = "n"; key = "<leader><leader>"; action.__raw = "function() require('snacks').picker.smart() end"; options.desc = "Smart Find Files"; }
    { mode = "n"; key = "<leader>/"; action.__raw = "function() require('snacks').picker.grep() end"; options.desc = "Grep"; }
    { mode = "n"; key = "<leader>e"; action.__raw = "function() require('snacks').explorer() end"; options.desc = "File Explorer"; }
    { mode = "n"; key = "<leader>,"; action.__raw = "function() require('snacks').picker.buffers() end"; options.desc = "Buffers"; }
    { mode = "n"; key = "<leader>."; action.__raw = "function() require('snacks').scratch() end"; options.desc = "Toggle Scratch Buffer"; }
    { mode = "n"; key = "<leader>S"; action.__raw = "function() require('snacks').scratch.select() end"; options.desc = "Select Scratch Buffer"; }
    { mode = "n"; key = "<leader>ff"; action.__raw = "function() require('snacks').picker.files() end"; options.desc = "Find Files"; }
    { mode = "n"; key = "<leader>fr"; action.__raw = "function() require('snacks').picker.recent() end"; options.desc = "Recent Files"; }
    { mode = "n"; key = "<leader>fb"; action.__raw = "function() require('snacks').picker.buffers() end"; options.desc = "Buffers"; }
    { mode = "n"; key = "<leader>fm"; action.__raw = "function() require('snacks').picker.marks() end"; options.desc = "Marks"; }
    { mode = "n"; key = "<leader>fg"; action.__raw = "function() require('snacks').picker.git_files() end"; options.desc = "Git Files"; }
    { mode = "n"; key = "<leader>fn"; action.__raw = "function() require('snacks').picker.files({ cwd = '/etc/nixos' }) end"; options.desc = "Find in /etc/nixos"; }
    { mode = "n"; key = "<leader>ft"; action.__raw = "function() require('snacks').terminal() end"; options.desc = "Terminal"; }
    { mode = "t"; key = "<C-/>"; action.__raw = "function() require('snacks').terminal() end"; options.desc = "Toggle Terminal"; }

    # Harpoon
    { mode = "n"; key = "<leader>ha"; action.__raw = "function() require('harpoon'):list():add(); vim.notify('Harpoon: pinned ' .. vim.fn.expand('%:t')) end"; options.desc = "Harpoon Add File"; }
    { mode = "n"; key = "<leader>hh"; action.__raw = "function() local h = require('harpoon'); h.ui:toggle_quick_menu(h:list()) end"; options.desc = "Harpoon Menu"; }
    { mode = "n"; key = "<leader>hc"; action.__raw = "function() require('harpoon'):list():clear(); vim.notify('Harpoon: cleared') end"; options.desc = "Harpoon Clear"; }
    { mode = "n"; key = "<leader>1"; action.__raw = "function() require('harpoon'):list():select(1) end"; options.desc = "Harpoon File 1"; }
    { mode = "n"; key = "<leader>2"; action.__raw = "function() require('harpoon'):list():select(2) end"; options.desc = "Harpoon File 2"; }
    { mode = "n"; key = "<leader>3"; action.__raw = "function() require('harpoon'):list():select(3) end"; options.desc = "Harpoon File 3"; }
    { mode = "n"; key = "<leader>4"; action.__raw = "function() require('harpoon'):list():select(4) end"; options.desc = "Harpoon File 4"; }
    { mode = "n"; key = "<leader>5"; action.__raw = "function() require('harpoon'):list():select(5) end"; options.desc = "Harpoon File 5"; }

    # Git
    { mode = "n"; key = "<leader>gg"; action.__raw = "function() require('snacks').lazygit() end"; options.desc = "Lazygit"; }
    { mode = "n"; key = "<leader>gd"; action = "<cmd>DiffviewOpen<cr>"; options.desc = "Diffview Open"; }
    { mode = "n"; key = "<leader>gH"; action = "<cmd>DiffviewFileHistory %<cr>"; options.desc = "Diffview File History"; }
    { mode = "n"; key = "<leader>gD"; action = "<cmd>DiffviewClose<cr>"; options.desc = "Diffview Close"; }
    { mode = [ "n" "v" ]; key = "<leader>gB"; action.__raw = "function() require('snacks').gitbrowse() end"; options.desc = "Git Browse (GitHub)"; }
    { mode = "n"; key = "<leader>gl"; action.__raw = "function() require('snacks').picker.git_log() end"; options.desc = "Git Log"; }
    { mode = "n"; key = "<leader>gb"; action.__raw = "function() require('snacks').picker.git_branches() end"; options.desc = "Git Branches"; }
    { mode = "n"; key = "<leader>gs"; action.__raw = "function() require('snacks').picker.git_status() end"; options.desc = "Git Status"; }

    # Search & Replace
    { mode = "n"; key = "<leader>ss"; action.__raw = "function() require('snacks').picker.lsp_symbols() end"; options.desc = "Goto Symbol"; }
    { mode = "n"; key = "<leader>sS"; action.__raw = "function() require('snacks').picker.lsp_workspace_symbols() end"; options.desc = "Workspace Symbols"; }
    { mode = "n"; key = "<leader>sw"; action.__raw = "function() require('snacks').picker.grep_word() end"; options.desc = "Grep Word"; }
    { mode = "n"; key = "<leader>sk"; action.__raw = "function() require('snacks').picker.keymaps() end"; options.desc = "Keymaps"; }
    { mode = "n"; key = "<leader>sd"; action.__raw = "function() require('snacks').picker.diagnostics() end"; options.desc = "Diagnostics Picker"; }
    { mode = "n"; key = "<leader>sn"; action.__raw = "function() require('snacks').notifier.show_history() end"; options.desc = "Notification History"; }
    { mode = "n"; key = "<leader>sc"; action.__raw = "function() require('snacks').picker.commands() end"; options.desc = "Commands"; }
    { mode = "n"; key = "<leader>sh"; action.__raw = "function() require('snacks').picker.help() end"; options.desc = "Help Pages"; }
    { mode = "n"; key = "<leader>sy"; action = "<cmd>YankyRingHistory<cr>"; options.desc = "Yank History"; }
    { mode = "n"; key = "<leader>su"; action = "<cmd>UndotreeToggle<cr>"; options.desc = "Undo Tree"; }
    { mode = [ "n" "v" ]; key = "<leader>sr"; action.__raw = "function() require('grug-far').open() end"; options.desc = "Search & Replace (Grug-Far)"; }

    # Code
    { mode = "n"; key = "<leader>cf"; action.__raw = "function() require('conform').format({ async = true, lsp_format = 'fallback' }) end"; options.desc = "Format Buffer"; }
    { mode = "v"; key = "<leader>cf"; action.__raw = "function() require('conform').format({ async = true, lsp_format = 'fallback', range = true }) end"; options.desc = "Format Range"; }
    { mode = "n"; key = "<leader>cr"; action.__raw = "function() return ':IncRename ' .. vim.fn.expand('<cword>') end"; options = { expr = true; desc = "Incremental Rename"; }; }
    { mode = "n"; key = "<leader>cR"; action.__raw = "function() require('snacks').rename.rename_file() end"; options.desc = "LSP Rename File"; }
    { mode = "n"; key = "<leader>cs"; action = "<cmd>AerialToggle!<cr>"; options.desc = "Symbols Outline (Aerial)"; }
    { mode = "n"; key = "<leader>cj"; action.__raw = "function() require('treesj').toggle() end"; options.desc = "Split / Join Block (TreeSJ)"; }
    { mode = "n"; key = "<leader>cg"; action.__raw = "function() require('neogen').generate() end"; options.desc = "Generate Docstring (Neogen)"; }
    { mode = "n"; key = "<leader>cp"; action = "<cmd>SmartPreview<cr>"; options.desc = "Toggle Markdown/Typst Preview"; }
    { mode = [ "n" "v" ]; key = "<leader>ct"; action = "<cmd>CshubTerm<cr>"; options.desc = "Capture Term -> CS Hub"; }
    { mode = "n"; key = "<leader>cA"; action = "<cmd>CshubAdd<cr>"; options.desc = "Add Exam/HW/Task -> CS Hub"; }
    { mode = "n"; key = "<leader>cH"; action = "<cmd>CshubDash<cr>"; options.desc = "CS Hub Dashboard & Calendar"; }
    { mode = "n"; key = "<leader>cT"; action = "<cmd>Cstest<cr>"; options.desc = "Run dotnet test"; }
    { mode = "n"; key = "<leader>oa"; action.__raw = "function() require('otter').activate({'javascript','css'}, true, true, nil) end"; options.desc = "Otter Activate (JS/CSS in HTML)"; }

    # Refactoring & Tasks
    { mode = "x"; key = "<leader>re"; action = "<cmd>Refactor extract<cr>"; options.desc = "Extract Function"; }
    { mode = "x"; key = "<leader>rf"; action = "<cmd>Refactor extract_to_file<cr>"; options.desc = "Extract Function to File"; }
    { mode = "x"; key = "<leader>rv"; action = "<cmd>Refactor extract_var<cr>"; options.desc = "Extract Variable"; }
    { mode = [ "n" "x" ]; key = "<leader>ri"; action = "<cmd>Refactor inline_var<cr>"; options.desc = "Inline Variable"; }
    { mode = "n"; key = "<leader>rr"; action = "<cmd>OverseerRun<cr>"; options.desc = "Overseer Run Task"; }
    { mode = "n"; key = "<leader>rt"; action = "<cmd>OverseerToggle<cr>"; options.desc = "Overseer Toggle Drawer"; }
    { mode = "n"; key = "<leader>ro"; action = "<cmd>OverseerQuickAction<cr>"; options.desc = "Overseer Quick Action"; }

    # Testing
    { mode = "n"; key = "<leader>tt"; action.__raw = "function() require('neotest').run.run() end"; options.desc = "Run Nearest Test"; }
    { mode = "n"; key = "<leader>tf"; action.__raw = "function() require('neotest').run.run(vim.fn.expand('%')) end"; options.desc = "Run File Tests"; }
    { mode = "n"; key = "<leader>ta"; action.__raw = "function() require('neotest').run.run(vim.fn.getcwd()) end"; options.desc = "Run All Tests"; }
    { mode = "n"; key = "<leader>ts"; action.__raw = "function() require('neotest').summary.toggle() end"; options.desc = "Toggle Test Summary"; }
    { mode = "n"; key = "<leader>to"; action.__raw = "function() require('neotest').output.open({ enter = true, auto_close = true }) end"; options.desc = "Test Output Float"; }
    { mode = "n"; key = "<leader>tO"; action.__raw = "function() require('neotest').output_panel.toggle() end"; options.desc = "Test Output Panel"; }
    { mode = "n"; key = "<leader>td"; action.__raw = "function() require('neotest').run.run({ strategy = 'dap' }) end"; options.desc = "Debug Nearest Test"; }
    { mode = "n"; key = "<leader>tS"; action.__raw = "function() require('neotest').run.stop() end"; options.desc = "Stop Test"; }

    # Database
    { mode = "n"; key = "<leader>Db"; action = "<cmd>DBUIToggle<cr>"; options.desc = "Toggle DBUI (Oracle/SQL)"; }
    { mode = "n"; key = "<leader>Df"; action = "<cmd>DBUIFindBuffer<cr>"; options.desc = "DBUI Find Buffer"; }
    { mode = "n"; key = "<leader>Ds"; action = "<cmd>DBUIRenameBuffer<cr>"; options.desc = "DBUI Rename Buffer"; }
    { mode = "n"; key = "<leader>Dl"; action = "<cmd>DBUILastQueryInfo<cr>"; options.desc = "DBUI Last Query Info"; }

    # Debugger
    { mode = "n"; key = "<leader>db"; action.__raw = "function() require('dap').toggle_breakpoint() end"; options.desc = "Toggle Breakpoint"; }
    { mode = "n"; key = "<leader>dB"; action.__raw = "function() require('dap').set_breakpoint(vim.fn.input('Condition: ')) end"; options.desc = "Conditional Breakpoint"; }
    { mode = "n"; key = "<leader>dL"; action.__raw = "function() require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end"; options.desc = "Logpoint"; }
    { mode = "n"; key = "<leader>dc"; action.__raw = "function() require('dap').continue() end"; options.desc = "Continue/Start"; }
    { mode = "n"; key = "<leader>do"; action.__raw = "function() require('dap').step_over() end"; options.desc = "Step Over"; }
    { mode = "n"; key = "<leader>di"; action.__raw = "function() require('dap').step_into() end"; options.desc = "Step Into"; }
    { mode = "n"; key = "<leader>dO"; action.__raw = "function() require('dap').step_out() end"; options.desc = "Step Out"; }
    { mode = "n"; key = "<leader>dC"; action.__raw = "function() require('dap').run_to_cursor() end"; options.desc = "Run to Cursor"; }
    { mode = "n"; key = "<leader>dl"; action.__raw = "function() require('dap').run_last() end"; options.desc = "Run Last"; }
    { mode = "n"; key = "<leader>dr"; action.__raw = "function() require('dap').repl.toggle() end"; options.desc = "Toggle REPL"; }
    { mode = "n"; key = "<leader>dt"; action.__raw = "function() require('dap').terminate() end"; options.desc = "Terminate"; }
    { mode = "n"; key = "<leader>du"; action.__raw = "function() require('dapui').toggle() end"; options.desc = "Toggle DAP UI"; }
    { mode = [ "n" "v" ]; key = "<leader>de"; action.__raw = "function() require('dapui').eval() end"; options.desc = "Evaluate"; }
    { mode = "n"; key = "<F5>"; action.__raw = "function() require('dap').continue() end"; options.desc = "DAP Continue"; }
    { mode = "n"; key = "<F10>"; action.__raw = "function() require('dap').step_over() end"; options.desc = "DAP Step Over"; }
    { mode = "n"; key = "<F11>"; action.__raw = "function() require('dap').step_into() end"; options.desc = "DAP Step Into"; }

    # Diagnostics
    { mode = "n"; key = "<leader>xx"; action = "<cmd>Trouble diagnostics toggle filter.buf=0<cr>"; options.desc = "Diagnostics (Buffer)"; }
    { mode = "n"; key = "<leader>xX"; action = "<cmd>Trouble diagnostics toggle<cr>"; options.desc = "Diagnostics (Workspace)"; }
    { mode = "n"; key = "<leader>xq"; action = "<cmd>Trouble qflist toggle<cr>"; options.desc = "Quickfix (Trouble)"; }
    { mode = "n"; key = "<leader>xl"; action = "<cmd>Trouble loclist toggle<cr>"; options.desc = "Loclist (Trouble)"; }
    { mode = "n"; key = "<leader>xt"; action = "<cmd>Trouble todo toggle<cr>"; options.desc = "TODOs (Trouble)"; }
    { mode = "n"; key = "<leader>xr"; action = "<cmd>Trouble lsp toggle focus=false win.position=right<cr>"; options.desc = "LSP Refs/Defs (Trouble)"; }

    # Sessions
    { mode = "n"; key = "<leader>qs"; action.__raw = "function() require('persistence').load() end"; options.desc = "Restore Session"; }
    { mode = "n"; key = "<leader>qS"; action.__raw = "function() require('persistence').select() end"; options.desc = "Select Session"; }
    { mode = "n"; key = "<leader>ql"; action.__raw = "function() require('persistence').load({ last = true }) end"; options.desc = "Restore Last Session"; }

    # Windows
    { mode = "n"; key = "<leader>w-"; action = "<C-w>s"; options.desc = "Split below"; }
    { mode = "n"; key = "<leader>w\\"; action = "<C-w>v"; options.desc = "Split right"; }
    { mode = "n"; key = "<leader>wd"; action = "<C-w>c"; options.desc = "Close window"; }
    { mode = "n"; key = "<leader>wm"; action.__raw = "function() require('snacks').zen.zoom() end"; options.desc = "Zoom Window"; }

    # UI Toggles
    { mode = "n"; key = "<leader>uf"; action.__raw = "function() vim.g.format_on_save = not (vim.g.format_on_save ~= false); vim.notify('Format on save: ' .. (vim.g.format_on_save and 'ON' or 'OFF')) end"; options.desc = "Toggle Format on Save"; }
    { mode = "n"; key = "<leader>uh"; action = "<cmd>Hardtime toggle<cr>"; options.desc = "Toggle Hardtime"; }
    { mode = "n"; key = "<leader>um"; action = "<cmd>MotionReport<cr>"; options.desc = "Motion Coach Report"; }
    { mode = "n"; key = "<leader>ui"; action.__raw = "function() local en = not vim.lsp.inlay_hint.is_enabled({ bufnr = 0 }); vim.lsp.inlay_hint.enable(en, { bufnr = 0 }); vim.notify('Inlay hints: ' .. (en and 'ON' or 'OFF')) end"; options.desc = "Toggle Inlay Hints"; }
    { mode = "n"; key = "<leader>un"; action = "<cmd>set number!<cr>"; options.desc = "Toggle Line Numbers"; }
    { mode = "n"; key = "<leader>uw"; action = "<cmd>set wrap!<cr>"; options.desc = "Toggle Wrap"; }
    { mode = "n"; key = "<leader>us"; action = "<cmd>set spell!<cr>"; options.desc = "Toggle Spell"; }
    { mode = "n"; key = "<leader>ut"; action = "<cmd>TSContext toggle<cr>"; options.desc = "Toggle Sticky Context"; }
    { mode = "n"; key = "<leader>uz"; action.__raw = "function() require('snacks').zen() end"; options.desc = "Toggle Zen Focus Mode"; }
    { mode = "n"; key = "<leader>uD"; action.__raw = "function() local d = require('snacks').dim; if d.enabled then d.disable() else d.enable() end end"; options.desc = "Toggle Scope Dimming"; }
    { mode = "n"; key = "<leader>ub"; action = "<cmd>Gitsigns toggle_current_line_blame<cr>"; options.desc = "Toggle Inline Git Blame"; }

    # LSP References
    { mode = [ "n" "t" ]; key = "]]"; action.__raw = "function() require('snacks').words.jump(vim.v.count1) end"; options.desc = "Next Reference"; }
    { mode = [ "n" "t" ]; key = "[["; action.__raw = "function() require('snacks').words.jump(-vim.v.count1) end"; options.desc = "Prev Reference"; }
  ];
}
