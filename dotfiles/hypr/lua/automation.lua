-- Live Hyprland 0.57.2 Lua Automation Engine:
--   * Smart Gaps / Smart Borders (single-window focus maximizes screen real estate)
--   * Submap live border & ambient glow shift + native HUD toast
--   * Screenshare Privacy Guard (auto-DND + red cue + Waybar badge)
--   * Urgent window toast notifications
--   * Native Colemak-DH / QWERTY toggle, compositor zoom, float-center-70%, opaque toggle & monitor throw
local theme = require("theme")
local M = {}

local P = theme.palette
local state = {
    smart_gaps_enabled = true,
    smart_gaps_active  = false,
    zoom_level         = 1.0,
    submap_notif       = nil,
    screenshare_active = false,
    current_layout     = "dwindle",
}

local function file_exists(path)
    local f = io.open(path, "r")
    if f then f:close(); return true end
    return false
end

local function write_flag(path, active)
    if active then
        local f = io.open(path, "w")
        if f then f:write("1\n"); f:close() end
    else
        os.remove(path)
    end
end

local function is_game_or_study_mode()
    return file_exists("/tmp/dyna-game-mode") or file_exists("/tmp/dyna-study-mode")
end

-- Pure Lua Colemak-DH / QWERTY toggle (instant, zero subshell)
function M.toggle_colemak()
    local cur = hl.get_config("input.kb_variant") or ""
    if cur == "colemak_dh" then
        hl.config({ input = { kb_variant = "" } })
        hl.notification.create({
            text      = "Keyboard -> QWERTY",
            timeout   = 1800,
            color     = "rgba(" .. P.blue .. "ee)",
            font_size = 13,
        })
    else
        hl.config({ input = { kb_variant = "colemak_dh" } })
        hl.notification.create({
            text      = "Keyboard -> Colemak-DH",
            timeout   = 1800,
            color     = "rgba(" .. P.mauve .. "ee)",
            font_size = 13,
        })
    end
end

-- Smart gaps: when focused workspace has exactly 1 tiled window, tighten gaps for clean focus
function M.refresh_smart_gaps()
    if not state.smart_gaps_enabled or is_game_or_study_mode() then
        return
    end
    local ws = hl.get_active_workspace()
    if not ws or ws.special then return end
    local wins = hl.get_workspace_windows(ws.id) or {}
    local tiled = 0
    for _, w in ipairs(wins) do
        if w.mapped and not w.floating and not w.hidden then
            tiled = tiled + 1
        end
    end
    local want_single = (tiled == 1)
    if want_single ~= state.smart_gaps_active then
        state.smart_gaps_active = want_single
        if want_single then
            hl.config({
                general    = { gaps_in = 3, gaps_out = 6 },
                decoration = { rounding = 10 },
            })
        else
            hl.config({
                general    = { gaps_in = 5, gaps_out = 10 },
                decoration = { rounding = 12 },
            })
        end
    end
end

function M.toggle_smart_gaps()
    state.smart_gaps_enabled = not state.smart_gaps_enabled
    if not state.smart_gaps_enabled then
        state.smart_gaps_active = false
        hl.config({
            general    = { gaps_in = 5, gaps_out = 10 },
            decoration = { rounding = 12 },
        })
    else
        M.refresh_smart_gaps()
    end
    hl.notification.create({
        text      = "Smart Gaps: " .. (state.smart_gaps_enabled and "ON" or "OFF"),
        timeout   = 1800,
        color     = "rgba(" .. P.mauve .. "ee)",
        font_size = 13,
    })
end

-- Smooth compositor zoom (ideal for inspecting UIs, dense PDFs, or showing code)
function M.zoom_delta(delta)
    state.zoom_level = math.max(1.0, math.min(4.0, state.zoom_level + delta))
    hl.config({ cursor = { zoom_factor = state.zoom_level } })
end

function M.zoom_reset()
    state.zoom_level = 1.0
    hl.config({ cursor = { zoom_factor = 1.0 } })
end

-- Float, resize to a crisp 70% of current monitor, and center
function M.float_center_focus()
    local w = hl.get_active_window()
    local m = hl.get_active_monitor()
    if not w or not m then return end
    if not w.floating then
        hl.dispatch(hl.dsp.window.float({ action = "toggle" }))
    end
    local tw = math.floor((m.width or 1920) * 0.70)
    local th = math.floor((m.height or 1080) * 0.74)
    hl.dispatch(hl.dsp.window.resize({ exact = true, x = tw, y = th }))
    hl.dispatch(hl.dsp.window.center())
end

-- Toggle forced full opacity on active window
function M.toggle_opaque()
    hl.dispatch(hl.dsp.window.set_prop({ prop = "opaque", action = "toggle" }))
end

-- Throw active window to the other monitor & focus it
function M.throw_to_other_monitor()
    local monitors = hl.get_monitors() or {}
    if #monitors < 2 then return end
    local cur = hl.get_active_monitor()
    if not cur then return end
    for _, m in ipairs(monitors) do
        if m.name ~= cur.name and m.active_workspace then
            hl.dispatch(hl.dsp.window.move({ workspace = m.active_workspace.id }))
            return
        end
    end
end

-- Cycle tiled layout: dwindle -> master -> scrolling -> dwindle
function M.cycle_layout(target)
    local order = { "dwindle", "master", "scrolling" }
    local next_l = target
    if not next_l then
        for idx, l in ipairs(order) do
            if l == state.current_layout then
                next_l = order[(idx % #order) + 1]
                break
            end
        end
    end
    state.current_layout = next_l or "dwindle"
    hl.config({ general = { layout = state.current_layout } })
    hl.notification.create({
        text      = "Layout -> " .. state.current_layout:upper(),
        timeout   = 1800,
        color     = "rgba(" .. P.sky .. "ee)",
        font_size = 13,
    })
end

function M.setup()
    -- Submap visual feedback (border + glow color shift + live native HUD toast)
    local submap_meta = {
        resize = {
            primary = P.peach, secondary = P.yellow,
            hint = "RESIZE  [n/e/i/o or arrows]  [Shift: fine]  [c: center]  [s: split]  [Esc: exit]",
        },
        group = {
            primary = P.teal, secondary = P.green,
            hint = "GROUP   [t: toggle]  [n/o: tab]  [l: lock]  [Shift+n/e/i/o: move]  [Esc: exit]",
        },
        layout = {
            primary = P.sky, secondary = P.sapphire,
            hint = "LAYOUT  [d: dwindle]  [m: master]  [s: scroll]  [c: center70]  [g: smart-gaps]  [=/-/0: zoom]  [Esc: exit]",
        },
    }

    hl.on("keybinds.submap", function(name)
        if state.submap_notif then
            pcall(function() state.submap_notif:dismiss() end)
            state.submap_notif = nil
        end
        local meta = name and submap_meta[name] or nil
        if meta then
            theme.set_border_override(meta.primary, meta.secondary)
            state.submap_notif = hl.notification.create({
                text      = meta.hint,
                timeout   = 30000,
                color     = "rgba(" .. meta.primary .. "ee)",
                font_size = 13,
            })
        else
            if state.screenshare_active then
                theme.set_border_override(P.red, P.maroon)
            else
                theme.set_border_override(nil)
            end
        end
    end)

    -- Screenshare Privacy Guard: auto-DND + red border cue + Waybar badge
    hl.on("screenshare.state", function(active)
        local is_on = (active == true or active == 1)
        if is_on == state.screenshare_active then return end
        state.screenshare_active = is_on
        write_flag("/tmp/dyna-screenshare", is_on)
        if is_on then
            theme.set_border_override(P.red, P.maroon)
            hl.exec_cmd("sh -c 'swaync-client -dn >/dev/null 2>&1 || true; pkill -RTMIN+9 waybar 2>/dev/null || true'")
            hl.notification.create({
                text      = "Screenshare ACTIVE — Notifications muted (DND)",
                timeout   = 3000,
                color     = "rgba(" .. P.red .. "ee)",
                font_size = 13,
            })
        else
            theme.set_border_override(nil)
            if not file_exists("/tmp/dyna-study-mode") then
                hl.exec_cmd("sh -c 'swaync-client -df >/dev/null 2>&1 || true; pkill -RTMIN+9 waybar 2>/dev/null || true'")
            else
                hl.exec_cmd("sh -c 'pkill -RTMIN+9 waybar 2>/dev/null || true'")
            end
            hl.notification.create({
                text      = "Screenshare ended — Privacy guard cleared",
                timeout   = 2000,
                color     = "rgba(" .. P.green .. "ee)",
                font_size = 13,
            })
        end
    end)

    -- Urgent window subtle alert (great on dual monitor)
    hl.on("window.urgent", function(win)
        if not win then return end
        local cls = win.class or "Window"
        local ws = win.workspace and tostring(win.workspace.id or win.workspace.name) or "?"
        hl.notification.create({
            text      = "Urgent: " .. cls .. " (WS " .. ws .. ")",
            timeout   = 2500,
            color     = "rgba(" .. P.yellow .. "ee)",
            font_size = 12,
        })
    end)

    -- Smart gaps triggers
    hl.on("window.open",              function() M.refresh_smart_gaps() end)
    hl.on("window.close",             function() M.refresh_smart_gaps() end)
    hl.on("window.move_to_workspace", function() M.refresh_smart_gaps() end)
    hl.on("workspace.active",         function() M.refresh_smart_gaps() end)
    hl.on("monitor.focused",          function() M.refresh_smart_gaps() end)
end

return M
