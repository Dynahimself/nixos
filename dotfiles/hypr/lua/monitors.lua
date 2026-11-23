local M = {}

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
    })

    -- External fallback
    hl.monitor({
        output   = "",
        mode     = "highrr",
        position = "auto",
        scale    = "auto",
    })

    -- Pin WS 1-5 to DP-3, WS 6-10 to HDMI-A-1
    local monitors = hl.get_monitors() or {}
    local has_dp3, has_hdmi = false, false
    for _, m in ipairs(monitors) do
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
