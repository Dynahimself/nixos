{ pkgs }:
{
  extraConfigLua = ''
    -- =====================================================================
    -- Dyna's Colemak-DH Motion Coach (Privacy-Safe Habit Logger -> Hardtime)
    -- =====================================================================
    -- ONLY observes Normal, Visual, and Operator-pending modes on real file
    -- buffers. NEVER logs Insert, Command-line, Replace, or Terminal text.
    -- Saves 1 compact JSON summary per session to:
    --   ~/.local/share/nvim/motion-coach/sessions.jsonl
    -- Commands: :MotionReport [N] (<leader>um), :MotionLogToggle,
    --           :MotionLogFlush, :MotionLogArchive
    -- =====================================================================
    do
      local M = {}
      local data_dir = vim.fn.stdpath("data") .. "/motion-coach"
      local log_file = data_dir .. "/sessions.jsonl"
      local enabled = true
      local start_ts = os.time()
      local ns = vim.api.nvim_create_namespace("dyna_motion_coach")

      local ignored_ft = {
        qf = true, help = true, Trouble = true, trouble = true, aerial = true,
        ["grug-far"] = true, oil = true, harpoon = true, DiffviewFiles = true,
        DiffviewFileHistory = true, OverseerList = true, undotree = true,
        ["neotest-summary"] = true, ["neotest-output"] = true,
        ["neotest-output-panel"] = true, Glance = true, snacks_dashboard = true,
        snacks_picker_list = true, snacks_picker_input = true,
        snacks_terminal = true, dapui_scopes = true, dapui_breakpoints = true,
        dapui_stacks = true, dapui_watches = true, ["dap-repl"] = true,
        dbui = true, dbout = true, motion_report = true,
      }

      local streak_keys = {
        n = true, e = true, i = true, o = true,
        w = true, b = true, j = true, x = true, u = true,
        ["<Up>"] = true, ["<Down>"] = true, ["<Left>"] = true, ["<Right>"] = true,
        ["<BS>"] = true, ["<Space>"] = true,
      }

      local state = {
        total_motions = 0,
        filetypes = {},
        streaks = {},
        patterns = {},
        good_habits = {},
        bigrams = {},
        trigrams = {},
      }

      local last_key = nil
      local run_len = 0
      local pending_count = false
      local recent = {} -- rolling last 4 Normal/Visual/Op keys

      local function inc(tbl, k, by)
        tbl[k] = (tbl[k] or 0) + (by or 1)
      end

      local function flush_streak()
        if last_key and streak_keys[last_key] and run_len >= 3 then
          local s = state.streaks[last_key]
          if not s then
            s = { count_3plus = 0, count_5plus = 0, max_len = 0, total_presses = 0 }
            state.streaks[last_key] = s
          end
          s.count_3plus = s.count_3plus + 1
          if run_len >= 5 then s.count_5plus = s.count_5plus + 1 end
          if run_len > s.max_len then s.max_len = run_len end
          s.total_presses = s.total_presses + run_len

          if (last_key == "e" or last_key == "i") and run_len >= 4 then
            inc(state.patterns, "repeat_e_i")
          elseif (last_key == "n" or last_key == "o") and run_len >= 4 then
            inc(state.patterns, "repeat_n_o")
          elseif (last_key == "w" or last_key == "b" or last_key == "j") and run_len >= 4 then
            inc(state.patterns, "repeat_w_b_j")
          elseif last_key == "x" and run_len >= 3 then
            inc(state.patterns, "x_spam")
          elseif last_key == "u" and run_len >= 4 then
            inc(state.patterns, "u_spam")
          end
        end
        last_key = nil
        run_len = 0
      end

      local function norm_key(typed)
        if not typed or typed == "" then return nil end
        local k = vim.fn.keytrans(typed)
        if not k or k == "" then return nil end
        -- Skip internal/plug/focus/mouse-release noise
        if k:match("^<Plug>") or k:match("Focus") or k:match("Release") or k:match("Drag") or k:match("Cursor") then
          return nil
        end
        return k
      end

      local function check_patterns()
        local n = #recent
        if n < 2 then return end
        local k1 = recent[n]
        local k2 = recent[n - 1]
        local k3 = n >= 3 and recent[n - 2] or ""
        local k4 = n >= 4 and recent[n - 3] or ""

        local p2 = k2 .. k1
        local p3 = k3 .. k2 .. k1
        local p4 = k4 .. k3 .. k2 .. k1

        if p2 == "^l" or p2 == "0l" then inc(state.patterns, "caret_l") end
        if p2 == "ol" and not k3:match("^[fFtT]$") then inc(state.patterns, "o_then_l") end
        if p2 == "$a" then inc(state.patterns, "dollar_a") end
        if p2 == "d$" then inc(state.patterns, "d_dollar") end
        if p2 == "c$" then inc(state.patterns, "c_dollar") end
        if p2 == "y$" then inc(state.patterns, "y_dollar") end
        if p2 == "Da" or p2 == "DA" then inc(state.patterns, "D_then_a") end
        if p2 == "0w" or p2 == "^w" then inc(state.patterns, "zero_w") end
        if p3 == "ddh" or p3 == "ddH" then inc(state.patterns, "dd_then_h") end
        if p3 == "dwl" or p3 == "dbl" or p3 == "djl" or p4 == "dlwl" or p4 == "dawl" then
          inc(state.patterns, "d_motion_then_l")
        end
        if (k3 == "v" or k3 == "V") and (k1 == "d" or k1 == "c") then
          inc(state.patterns, "visual_single_op")
        end
        if p3 == "vdl" or p3 == "Vdl" or (k2 == "d" and k1 == "l" and (k3 == "w" or k3 == "j" or k3 == "o" or k3 == "e")) then
          inc(state.patterns, "delete_then_insert")
        end
      end

      vim.on_key(function(_, typed)
        if not enabled then return end
        local mode = vim.api.nvim_get_mode().mode
        -- STRICT PRIVACY GUARD: ONLY Normal, Visual, and Operator-pending modes
        if not (mode == "n" or mode == "v" or mode == "V" or mode == "\22" or mode:sub(1, 2) == "no") then
          flush_streak()
          recent = {}
          pending_count = false
          return
        end

        local bt = vim.bo.buftype
        local ft = vim.bo.filetype
        if bt ~= "" or ignored_ft[ft] then
          return
        end

        local k = norm_key(typed)
        if not k then return end

        state.total_motions = state.total_motions + 1
        if ft ~= "" then inc(state.filetypes, ft) end

        -- Track arrow keys & mouse clicks
        if k == "<Up>" or k == "<Down>" or k == "<Left>" or k == "<Right>" then
          inc(state.patterns, "arrow_keys")
        elseif k:match("Mouse") or k:match("ScrollWheel") then
          inc(state.patterns, "mouse_usage")
        end

        -- Track count prefixes & good Vim habits
        if k:match("^[1-9]$") or (pending_count and k == "0") then
          pending_count = true
          flush_streak()
          return
        elseif pending_count then
          pending_count = false
          if k == "e" or k == "i" or k == "n" or k == "o" or k == "w" or k == "b" or k == "j" or k == "d" or k == "y" then
            inc(state.good_habits, "counted_motion")
          end
        end

        if mode == "n" then
          if k == "s" or k == "S" then inc(state.good_habits, "flash_jump")
          elseif k == "f" or k == "F" or k == "t" or k == "T" then inc(state.good_habits, "char_find")
          elseif k == "c" or k == "C" then inc(state.good_habits, "change_operator")
          elseif k == "D" or k == "Y" or k == "A" or k == "L" then inc(state.good_habits, "power_shortcut")
          end
        elseif mode:sub(1, 2) == "no" and (k == "l" or k == "a") then
          inc(state.good_habits, "text_object")
        end

        -- Streak tracking
        if streak_keys[k] then
          if k == last_key then
            run_len = run_len + 1
          else
            flush_streak()
            last_key = k
            run_len = 1
          end
        else
          flush_streak()
        end

        -- Rolling window for pattern + raw n-gram discovery (exclude <Esc>, leader, long sequences)
        if k == "<Esc>" or k == "<Space>" or k == "<CR>" then
          recent = {}
          return
        end

        table.insert(recent, k)
        if #recent > 4 then table.remove(recent, 1) end

        check_patterns()

        -- Record short readable 2-grams & 3-grams of pure single-char motions
        local n = #recent
        if n >= 2 and #recent[n] == 1 and #recent[n - 1] == 1 then
          local bg = recent[n - 1] .. recent[n]
          if bg ~= recent[n] .. recent[n] then -- non-repeats (repeats tracked in streaks)
            inc(state.bigrams, bg)
          end
        end
        if n >= 3 and #recent[n] == 1 and #recent[n - 1] == 1 and #recent[n - 2] == 1 then
          local tg = recent[n - 2] .. recent[n - 1] .. recent[n]
          if not (recent[n] == recent[n - 1] and recent[n - 1] == recent[n - 2]) then
            inc(state.trigrams, tg)
          end
        end
      end, ns)

      local function top_n(tbl, limit)
        local arr = {}
        for k, v in pairs(tbl) do
          if v >= 2 then table.insert(arr, { k = k, v = v }) end
        end
        table.sort(arr, function(a, b) return a.v > b.v end)
        local out = {}
        for idx = 1, math.min(#arr, limit) do
          out[arr[idx].k] = arr[idx].v
        end
        return out
      end

      function M.flush(force)
        flush_streak()
        if not force and state.total_motions < 15 then return false end
        vim.fn.mkdir(data_dir, "p")
        local payload = {
          ts = os.date("!%Y-%m-%dT%H:%M:%SZ"),
          host = vim.uv.os_gethostname() or "unknown",
          duration_sec = math.max(1, os.time() - start_ts),
          total_motions = state.total_motions,
          filetypes = state.filetypes,
          streaks = state.streaks,
          patterns = state.patterns,
          good_habits = state.good_habits,
          top_bigrams = top_n(state.bigrams, 25),
          top_trigrams = top_n(state.trigrams, 20),
        }
        local ok, line = pcall(vim.json.encode, payload)
        if not ok then return false end
        local f = io.open(log_file, "a")
        if not f then return false end
        f:write(line .. "\n")
        f:close()
        -- Reset counters after flush so :MotionLogFlush + VimLeavePre never double-count
        state = {
          total_motions = 0, filetypes = {}, streaks = {},
          patterns = {}, good_habits = {}, bigrams = {}, trigrams = {},
        }
        start_ts = os.time()
        return true
      end

      vim.api.nvim_create_autocmd("VimLeavePre", {
        callback = function() M.flush(false) end,
      })

      local ADVICE = {
        repeat_e_i        = { label = "Holding e/i (4+ lines)",        tip = "Use {count}e/{count}i, <C-d>/<C-u>, }/{, ]f/[f, or s (Flash)", lua = nil },
        repeat_n_o        = { label = "Holding n/o (4+ chars)",        tip = "Use w/b/j, f/t, or s (Flash) instead of creeping horizontally", lua = nil },
        repeat_w_b_j      = { label = "Spamming w/b/j (4+ words)",     tip = "Use f<char>/t<char> or s (Flash) to jump straight there", lua = nil },
        arrow_keys        = { label = "Arrow keys in Normal/Visual",   tip = "Stick to Colemak-DH home row n/e/i/o", lua = nil },
        mouse_usage       = { label = "Mouse clicks/scrolls",          tip = "Use s (Flash), <C-n/e/i/o> windows, or <leader><leader>", lua = nil },
        caret_l           = { label = "^l or 0l (line start + insert)",tip = "Use L (Insert at first non-blank)", lua = '["[%^0]l"] = { message = function() return "Use L instead of ^l / 0l" end, length = 2 },' },
        o_then_l          = { label = "ol (right + insert)",           tip = "Use a (append after cursor)", lua = '["[^fFtT]ol"] = { message = function() return "Use a instead of ol" end, length = 3 },' },
        dollar_a          = { label = "$a (line end + append)",        tip = "Use A (append at end of line)", lua = '["%$a"] = { message = function() return "Use A instead of $a" end, length = 2 },' },
        d_dollar          = { label = "d$ (delete to EOL)",            tip = "Use D instead of d$", lua = '["d%$"] = { message = function() return "Use D instead of d$" end, length = 2 },' },
        c_dollar          = { label = "c$ (change to EOL)",            tip = "Use C instead of c$", lua = '["c%$"] = { message = function() return "Use C instead of c$" end, length = 2 },' },
        y_dollar          = { label = "y$ (yank to EOL)",              tip = "Use Y instead of y$", lua = '["y%$"] = { message = function() return "Use Y instead of y$" end, length = 2 },' },
        D_then_a          = { label = "Da / DA (delete EOL + append)", tip = "Use C instead of Da/DA", lua = '["D[aA]"] = { message = function() return "Use C instead of Da/DA" end, length = 2 },' },
        dd_then_h         = { label = "ddh / ddH (del line + open)",   tip = "Use cc to replace the whole line cleanly", lua = '["dd[hH]"] = { message = function() return "Use cc instead of ddh/ddH" end, length = 3 },' },
        d_motion_then_l   = { label = "dwl / dbl / dlwl (del + ins)",  tip = "Use c<motion> (cw / clw) instead of d<motion>l", lua = '["d[wbj]l"] = { message = function(k) return "Use c" .. k:sub(2,2) .. " instead of " .. k end, length = 3 },' },
        delete_then_insert= { label = "Delete then Insert (..dl)",     tip = "Use c (change) instead of d + l", lua = '["[vV]dl"] = { message = function() return "Use c instead of visual d + l" end, length = 3 },' },
        x_spam            = { label = "Spamming x (3+ chars)",         tip = "Use dw / clw / df<char> / d{count}o", lua = '["xxx"] = { message = function() return "Use dw / clw / df<char> instead of xxx" end, length = 3 },' },
        u_spam            = { label = "Spamming u (4+ undos)",         tip = "Open <leader>su (Undotree) for branching undo", lua = nil },
        zero_w            = { label = "0w / ^w",                       tip = "Use f<char> or s (Flash) directly", lua = '["[0%^]w"] = { message = function() return "Jump directly with f<char> or s (Flash)" end, length = 2 },' },
        visual_single_op  = { label = "Visual select before single op",tip = "Apply operator+textobj directly (dlw, cl(, ylf)", lua = nil },
      }

      vim.api.nvim_create_user_command("MotionReport", function(opts)
        local limit = tonumber(opts.args) or 0
        local sessions = {}
        local f = io.open(log_file, "r")
        if f then
          for line in f:lines() do
            local ok, obj = pcall(vim.json.decode, line)
            if ok and type(obj) == "table" then table.insert(sessions, obj) end
          end
          f:close()
        end
        -- Include current live session preview if it has motions
        if state.total_motions > 0 then
          table.insert(sessions, {
            ts = "LIVE (current session)",
            total_motions = state.total_motions,
            streaks = state.streaks,
            patterns = state.patterns,
            good_habits = state.good_habits,
            top_bigrams = top_n(state.bigrams, 15),
            top_trigrams = top_n(state.trigrams, 10),
          })
        end

        if #sessions == 0 then
          return vim.notify("Motion Coach: no sessions logged yet — code normally and check back!", vim.log.levels.INFO)
        end

        if limit > 0 and #sessions > limit then
          local sliced = {}
          for i = #sessions - limit + 1, #sessions do table.insert(sliced, sessions[i]) end
          sessions = sliced
        end

        local tot_m, tot_bad, tot_good = 0, 0, 0
        local pat_sum, good_sum, streak_sum, bg_sum, tg_sum = {}, {}, {}, {}, {}
        for _, s in ipairs(sessions) do
          tot_m = tot_m + (s.total_motions or 0)
          for k, v in pairs(s.patterns or {}) do inc(pat_sum, k, v); tot_bad = tot_bad + v end
          for k, v in pairs(s.good_habits or {}) do inc(good_sum, k, v); tot_good = tot_good + v end
          for k, v in pairs(s.streaks or {}) do
            local cur = streak_sum[k] or { c3 = 0, c5 = 0, max = 0 }
            cur.c3 = cur.c3 + (v.count_3plus or 0)
            cur.c5 = cur.c5 + (v.count_5plus or 0)
            cur.max = math.max(cur.max, v.max_len or 0)
            streak_sum[k] = cur
          end
          for k, v in pairs(s.top_bigrams or {}) do inc(bg_sum, k, v) end
          for k, v in pairs(s.top_trigrams or {}) do inc(tg_sum, k, v) end
        end

        local lines = {
          "# Dyna's Colemak-DH Motion Coach Report",
          "",
          string.format("- **Sessions analyzed:** %d   |   **Total motions:** %d   |   **Bad-habit hits:** %d   |   **Power motions:** %d",
            #sessions, tot_m, tot_bad, tot_good),
          string.format("- **Log file:** `%s`", log_file),
          "",
          "## Top Personal Bad Habits (Ranked)",
        }

        local pat_arr = {}
        for k, v in pairs(pat_sum) do table.insert(pat_arr, { k = k, v = v }) end
        table.sort(pat_arr, function(a, b) return a.v > b.v end)

        if #pat_arr == 0 then
          table.insert(lines, "_No bad habits recorded yet — clean vimming!_")
        else
          for idx, item in ipairs(pat_arr) do
            local meta = ADVICE[item.k] or { label = item.k, tip = "" }
            table.insert(lines, string.format("%d. **%s** — `%dx` (%.1f/session) -> %s",
              idx, meta.label, item.v, item.v / #sessions, meta.tip))
          end
        end

        table.insert(lines, "")
        table.insert(lines, "## Longest Key-Repeat Streaks")
        local st_arr = {}
        for k, v in pairs(streak_sum) do table.insert(st_arr, { k = k, v = v }) end
        table.sort(st_arr, function(a, b) return a.v.c3 > b.v.c3 end)
        if #st_arr == 0 then
          table.insert(lines, "_No 3+ repeat streaks logged yet._")
        else
          for _, it in ipairs(st_arr) do
            table.insert(lines, string.format("- `%s`: **%dx** (3+ streak), **%dx** (5+ streak), max streak **%d**",
              it.k, it.v.c3, it.v.c5, it.v.max))
          end
        end

        table.insert(lines, "")
        table.insert(lines, "## Power-Motion Telemetry (Higher = Better)")
        local g_arr = {}
        for k, v in pairs(good_sum) do table.insert(g_arr, { k = k, v = v }) end
        table.sort(g_arr, function(a, b) return a.v > b.v end)
        if #g_arr == 0 then
          table.insert(lines, "_None yet._")
        else
          for _, it in ipairs(g_arr) do
            table.insert(lines, string.format("- `%s`: **%d**", it.k, it.v))
          end
        end

        table.insert(lines, "")
        table.insert(lines, "## Top Unclassified Recurring Sequences (Spot New Quirks)")
        local tg_arr = {}
        for k, v in pairs(tg_sum) do table.insert(tg_arr, { k = k, v = v }) end
        table.sort(tg_arr, function(a, b) return a.v > b.v end)
        local shown = 0
        for _, it in ipairs(tg_arr) do
          if shown >= 10 then break end
          table.insert(lines, string.format("- `%s`: %dx", it.k, it.v))
          shown = shown + 1
        end
        if shown == 0 then table.insert(lines, "_Need more sessions for 3-gram discovery._") end

        table.insert(lines, "")
        table.insert(lines, "## Suggested `hardtime.nvim` Hints (Ready for `nixvim/coding.nix`)")
        table.insert(lines, "```lua")
        local added = 0
        for _, item in ipairs(pat_arr) do
          local meta = ADVICE[item.k]
          if meta and meta.lua then
            table.insert(lines, "  " .. meta.lua)
            added = added + 1
          end
        end
        if added == 0 then
          table.insert(lines, "  -- Keep coding for a few sessions to generate personalized hints!")
        end
        table.insert(lines, "```")

        local buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
        vim.bo[buf].filetype = "markdown"
        vim.bo[buf].modifiable = false
        vim.bo[buf].bufhidden = "wipe"
        local w = math.min(104, math.floor(vim.o.columns * 0.84))
        local h = math.min(#lines + 2, math.floor(vim.o.lines * 0.80))
        vim.api.nvim_open_win(buf, true, {
          relative = "editor",
          width = w, height = h,
          row = math.floor((vim.o.lines - h) / 2),
          col = math.floor((vim.o.columns - w) / 2),
          style = "minimal", border = "rounded",
          title = " 󰌌 Motion Coach (q to close) ", title_pos = "center",
        })
        vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = buf, silent = true })
        vim.keymap.set("n", "<Esc>", "<cmd>close<cr>", { buffer = buf, silent = true })
      end, { nargs = "?", desc = "Show Motion Coach habit report" })

      vim.api.nvim_create_user_command("MotionLogToggle", function()
        enabled = not enabled
        vim.notify("Motion Coach logging: " .. (enabled and "ON" or "PAUSED"))
      end, { desc = "Toggle Motion Coach logging" })

      vim.api.nvim_create_user_command("MotionLogFlush", function()
        if M.flush(true) then
          vim.notify("Motion Coach: saved session snapshot to " .. log_file)
        else
          vim.notify("Motion Coach: failed to write log", vim.log.levels.ERROR)
        end
      end, { desc = "Flush current session motion stats now" })

      vim.api.nvim_create_user_command("MotionLogArchive", function()
        if vim.fn.filereadable(log_file) == 1 then
          local dest = data_dir .. "/sessions-" .. os.date("%Y%m%d-%H%M%S") .. ".jsonl"
          vim.fn.rename(log_file, dest)
          vim.notify("Motion Coach: archived old log to " .. dest)
        else
          vim.notify("Motion Coach: no active log to archive")
        end
      end, { desc = "Archive current Motion Coach log for a fresh baseline" })
    end
  '';
}
