local M = {}

local function drm_connected(name)
    for card = 0, 3 do
        local f = io.open("/sys/class/drm/card" .. card .. "-" .. name .. "/status", "r")
        if f then
            local status = (f:read("*l") or ""):gsub("%s+", "")
            f:close()
            if status == "connected" then return true end
        end
    end
    return false
end

function M.setup()
    -- Primary: AOC Q27G4ZMN 2560x1440@240Hz
    hl.monitor({
        output        = "DP-3",
        mode          = "2560x1440@240",
        position      = "0x0",
        scale         = 1,
        bitdepth      = 10,
        supports_hdr  = 1,
        sdrbrightness = 1.2,
        sdrsaturation = 1.0,
        vrr           = 2,
    })

    -- Secondary: ASUS VG249 1920x1080@144Hz
    hl.monitor({
        output   = "HDMI-A-1",
        mode     = "1920x1080@144",
        position = "2560x0",
        scale    = 1,
        vrr      = 2,
    })

    -- Laptop display
    hl.monitor({
        output   = "eDP-1",
        mode     = "1920x1080@144",
        position = "0x0",
        scale    = 1,
        vrr      = 0,
    })

    -- External fallback
    hl.monitor({
        output   = "",
        mode     = "highrr",
        position = "auto",
        scale    = "auto",
    })

    -- Pin WS 1-5 to DP-3, WS 6-10 to HDMI-A-1
    local has_dp3  = drm_connected("DP-3")
    local has_hdmi = drm_connected("HDMI-A-1")
    for _, m in ipairs(hl.get_monitors() or {}) do
        if m.name == "DP-3" then has_dp3 = true end
        if m.name == "HDMI-A-1" then has_hdmi = true end
    end

    if has_dp3 and has_hdmi then
        for i = 1, 5 do
            hl.workspace_rule({
                workspace  = tostring(i),
                monitor    = "DP-3",
                default    = (i == 1),
                persistent = true,
            })
        end
        for i = 6, 10 do
            hl.workspace_rule({
                workspace  = tostring(i),
                monitor    = "HDMI-A-1",
                default    = (i == 6),
                persistent = true,
            })
        end
    end
end

return M
