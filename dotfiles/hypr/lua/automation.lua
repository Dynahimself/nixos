local theme = require("theme")
local M = {}

local P = theme.palette
local state = {
    smart_gaps_enabled = false,
    smart_gaps_rule    = nil,
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

-- Toggle Colemak-DH / QWERTY
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

function M.toggle_smart_gaps()
    state.smart_gaps_enabled = not state.smart_gaps_enabled
    if state.smart_gaps_rule then
        state.smart_gaps_rule:set_enabled(state.smart_gaps_enabled)
    end
    hl.notification.create({
        text      = "Smart Gaps: " .. (state.smart_gaps_enabled and "ON" or "OFF"),
        timeout   = 1800,
        color     = "rgba(" .. P.mauve .. "ee)",
        font_size = 13,
    })
end

function M.zoom_delta(delta)
    state.zoom_level = math.max(1.0, math.min(4.0, state.zoom_level + delta))
    hl.config({ cursor = { zoom_factor = state.zoom_level } })
end

function M.zoom_reset()
    state.zoom_level = 1.0
    hl.config({ cursor = { zoom_factor = 1.0 } })
end

-- Float and center window at 70% monitor size
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

function M.toggle_opaque()
    hl.dispatch(hl.dsp.window.set_prop({ prop = "opaque", action = "toggle" }))
end

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
    -- Submap border override and HUD hint
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

    -- Screenshare DND guard
    hl.on("screenshare.state", function(active)
        local is_on = (active == true or active == 1)
        if is_on == state.screenshare_active then return end
        state.screenshare_active = is_on
        write_flag("/tmp/dyna-screenshare", is_on)
        if is_on then
            theme.set_border_override(P.red, P.maroon)
            hl.exec_cmd("sh -c 'swaync-client -dn >/dev/null 2>&1 || true; pkill -RTMIN+9 waybar 2>/dev/null || true'")
            hl.notification.create({
                text      = "Screenshare active: DND enabled",
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
                text      = "Screenshare ended: DND disabled",
                timeout   = 2000,
                color     = "rgba(" .. P.green .. "ee)",
                font_size = 13,
            })
        end
    end)

    -- Urgent window alert
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

    -- Native per-workspace smart gaps (off by default; toggle with SUPER+Z -> g)
    state.smart_gaps_rule = hl.workspace_rule({
        workspace = "w[tv1]",
        gaps_in   = 3,
        gaps_out  = 6,
        enabled   = state.smart_gaps_enabled,
    })
end

return M
