local theme = require("theme")
local M = {}

function M.setup()
    local P = theme.palette
    local acc = theme.load_accent()

    hl.config({
        general = {
            gaps_in                 = 5,
            gaps_out                = 10,
            float_gaps              = 10,
            border_size             = 2,
            extend_border_grab_area = 14,
            hover_icon_on_border    = true,
            layout                  = "dwindle",
            resize_on_border        = true,
            snap = {
                enabled        = true,
                window_gap     = 10,
                monitor_gap    = 10,
                border_overlap = false,
                respect_gaps   = true,
            },
        },

        decoration = {
            rounding           = 12,
            rounding_power     = 2.2,
            active_opacity     = 1.0,
            inactive_opacity   = 0.96,
            fullscreen_opacity = 1.0,
            dim_special        = 0.38,
            dim_modal          = true,
            blur = {
                enabled            = true,
                size               = 6,
                passes             = 3,
                new_optimizations  = true,
                ignore_opacity     = true,
                xray               = false,
                noise              = 0.014,
                contrast           = 0.96,
                brightness         = 0.86,
                vibrancy           = 0.22,
                vibrancy_darkness  = 0.08,
                special            = true,
                popups             = true,
                popups_ignorealpha = 0.2,
            },
            shadow = {
                enabled        = true,
                range          = 18,
                render_power   = 3,
                color          = "rgba(" .. P.crust .. "cc)",
                color_inactive = "rgba(" .. P.crust .. "88)",
            },
            glow = {
                enabled        = true,
                range          = 16,
                render_power   = 3,
                color          = "rgba(" .. acc.primary .. "55)",
                color_inactive = "rgba(" .. P.crust .. "00)",
            },
        },

        group = {
            auto_group           = true,
            drag_into_group      = 1,
            focus_removed_window = true,
            groupbar = {
                enabled             = true,
                font_family         = "JetBrainsMono Nerd Font",
                font_size           = 11,
                font_weight_active  = "bold",
                height              = 22,
                indicator_height    = 3,
                indicator_gap       = 2,
                rounding            = 8,
                gaps_in             = 4,
                gaps_out            = 4,
                render_titles       = true,
                middle_click_close  = true,
                blur                = true,
                text_color          = "rgba(" .. P.crust .. "ff)",
                text_color_inactive = "rgba(" .. P.subtext0 .. "ff)",
            },
        },

        animations = {
            enabled = true,
        },

        dwindle = {
            preserve_split       = true,
            smart_split          = false,
            smart_resizing       = true,
            special_scale_factor = 0.88,
        },

        master = {
            mfact                = 0.56,
            new_status           = "slave",
            special_scale_factor = 0.88,
        },

        binds = {
            allow_workspace_cycles           = true,
            workspace_back_and_forth         = false,
            movefocus_cycles_groupfirst      = true,
            hide_special_on_workspace_change = false,
        },

        cursor = {
            inactive_timeout       = 5,
            no_break_fs_vrr        = 2,
            enable_hyprcursor      = true,
            warp_on_monitor_change = 0,
        },

        render = {
            direct_scanout = 2,
            cm_enabled     = true,
        },

        misc = {
            force_default_wallpaper  = 0,
            disable_hyprland_logo    = true,
            disable_splash_rendering = true,
            key_press_enables_dpms   = true,
            mouse_move_enables_dpms  = true,
            vrr                      = 2,
            enable_swallow           = true,
            swallow_regex            = "^(ghostty|com\\.mitchellh\\.ghostty)$",
            focus_on_activate        = false,
            middle_click_paste       = true,
        },

        ecosystem = {
            no_update_news  = true,
            no_donation_nag = true,
        },

        input = {
            kb_layout    = "us",
            kb_variant   = "",
            follow_mouse = 1,
            sensitivity  = 0,
            repeat_delay = 260,
            repeat_rate  = 40,
            touchpad = {
                natural_scroll       = false,
                disable_while_typing = true,
                tap_to_click         = true,
            },
        },
    })

    theme.apply_accent(acc.primary, acc.secondary)

    -- Animations
    hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
    hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
    hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
    hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
    hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })
    hl.curve("snappy",         { type = "spring", mass = 1, stiffness = 320, damping = 35 })

    hl.animation({ leaf = "global",           enabled = true, speed = 10,  bezier = "default" })
    hl.animation({ leaf = "border",           enabled = true, speed = 5.0, bezier = "easeOutQuint" })
    hl.animation({ leaf = "windows",          enabled = true, speed = 4.2, spring = "snappy" })
    hl.animation({ leaf = "windowsIn",        enabled = true, speed = 3.8, spring = "snappy",       style = "popin 88%" })
    hl.animation({ leaf = "windowsOut",       enabled = true, speed = 1.6, bezier = "quick",        style = "popin 88%" })
    hl.animation({ leaf = "fadeIn",           enabled = true, speed = 1.8, bezier = "almostLinear" })
    hl.animation({ leaf = "fadeOut",          enabled = true, speed = 1.4, bezier = "almostLinear" })
    hl.animation({ leaf = "fade",             enabled = true, speed = 2.8, bezier = "quick" })
    hl.animation({ leaf = "layers",           enabled = true, speed = 3.4, bezier = "easeOutQuint" })
    hl.animation({ leaf = "layersIn",         enabled = true, speed = 3.2, bezier = "easeOutQuint", style = "popin 92%" })
    hl.animation({ leaf = "layersOut",        enabled = true, speed = 1.6, bezier = "quick",        style = "fade" })
    hl.animation({ leaf = "fadeLayersIn",     enabled = true, speed = 1.8, bezier = "almostLinear" })
    hl.animation({ leaf = "fadeLayersOut",    enabled = true, speed = 1.4, bezier = "almostLinear" })
    hl.animation({ leaf = "workspaces",       enabled = true, speed = 2.4, bezier = "easeOutQuint", style = "slidefade 16%" })
    hl.animation({ leaf = "specialWorkspace", enabled = true, speed = 2.6, bezier = "easeOutQuint", style = "slidevert" })
    hl.animation({ leaf = "zoomFactor",       enabled = true, speed = 6.0, bezier = "easeOutQuint" })

    hl.gesture({
        fingers   = 3,
        direction = "horizontal",
        action    = "workspace",
    })
end

return M
