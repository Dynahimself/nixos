local M = {}

function M.setup()
    -- Layer rules
    hl.layer_rule({
        name         = "waybar-glass",
        match        = { namespace = "^waybar$" },
        blur         = true,
        blur_popups  = true,
        ignore_alpha = 0.15,
    })

    hl.layer_rule({
        name         = "rofi-glass",
        match        = { namespace = "^rofi$" },
        blur         = true,
        ignore_alpha = 0.2,
        dim_around   = true,
        animation    = "popin 90%",
    })

    hl.layer_rule({
        name         = "swaync-panel-glass",
        match        = { namespace = "^swaync-control-center$" },
        blur         = true,
        ignore_alpha = 0.2,
        animation    = "slide right",
    })

    hl.layer_rule({
        name         = "swaync-toast-glass",
        match        = { namespace = "^swaync-notification-window$" },
        blur         = true,
        ignore_alpha = 0.2,
        animation    = "slide right",
    })

    hl.layer_rule({
        name         = "swayosd-glass",
        match        = { namespace = "^swayosd$" },
        blur         = true,
        ignore_alpha = 0.2,
        animation    = "popin 90%",
    })

    hl.layer_rule({
        name       = "wlogout-glass",
        match      = { namespace = "^logout_dialog$" },
        blur       = true,
        dim_around = true,
        animation  = "fade",
    })

    hl.layer_rule({
        name    = "slurp-no-anim",
        match   = { namespace = "^selection$" },
        no_anim = true,
    })

    -- Scratchpads
    hl.workspace_rule({
        workspace        = "special:scratchpad",
        on_created_empty = "ghostty",
    })

    hl.workspace_rule({
        workspace        = "special:notes",
        on_created_empty = "ghostty -e nvim /home/dyna/Documents/quick-notes.md",
    })

    hl.workspace_rule({
        workspace        = "special:monitor",
        on_created_empty = "ghostty -e btop",
    })

    hl.workspace_rule({
        workspace        = "special:music",
        on_created_empty = "spotify",
    })

    -- Window rules
    hl.window_rule({
        name           = "suppress-maximize-events",
        match          = { class = ".*" },
        suppress_event = "maximize",
    })

    hl.window_rule({
        name = "fix-xwayland-drags",
        match = {
            class      = "^$",
            title      = "^$",
            xwayland   = true,
            float      = true,
            fullscreen = false,
            pin        = false,
        },
        no_focus = true,
    })

    -- Steam
    hl.window_rule({ name = "steam-tile",          match = { class = "^(steam)$" }, tile = true })
    hl.window_rule({ name = "steam-friends-float", match = { class = "^(steam)$", title = "^(Friends List)$" }, float = true, size = "420 720" })
    hl.window_rule({ name = "steam-news-float",    match = { class = "^(steam)$", title = "^(.*- News.*)$" }, float = true })
    hl.window_rule({ name = "games-idle-inhibit",  match = { class = "^(steam_app_.*|gamescope|Minecraft.*)$" }, idle_inhibit = "fullscreen" })

    -- Workspace routing
    hl.window_rule({ name = "study-ws4",  match = { class = "^(anki|org\\.pwmt\\.zathura|sioyek)$" }, workspace = 4 })
    hl.window_rule({ name = "social-ws5", match = { class = "^(discord|vesktop|Spotify)$" }, workspace = 5 })

    -- PiP
    hl.window_rule({
        name              = "pip-float-pin",
        match             = { title = "^(Picture-in-Picture|Picture in picture)$" },
        float             = true,
        pin               = true,
        keep_aspect_ratio = true,
        size              = "640 360",
        move              = "monitor_w-660 monitor_h-380",
        opacity           = "1.0 override 1.0 override",
    })

    -- Zen Browser
    hl.window_rule({
        name         = "zen-media-idle",
        match        = { class = "^(zen)$" },
        idle_inhibit = "fullscreen",
    })

    hl.window_rule({
        name    = "zen-media-opaque",
        match   = { class = "^(zen)$", title = ".*(YouTube|Jellyfin|Twitch|Netflix|Prime Video|Crunchyroll).*" },
        opacity = "1.0 override 1.0 override",
    })

    hl.window_rule({
        name   = "zen-dialogs-float",
        match  = { class = "^(zen)$", title = "^(Library|About Zen Browser|Extension:.*|Opening .*|Enter name of file.*|Page Info.*|Clear Recent History)$" },
        float  = true,
        center = true,
    })

    -- Media
    hl.window_rule({
        name         = "mpv-opaque",
        match        = { class = "^(mpv)$" },
        opacity      = "1.0 override 1.0 override",
        idle_inhibit = "focus",
    })

    -- Dialogs
    hl.window_rule({
        name   = "floating-dialogs",
        match  = { title = "^(Open File|Save File|Save As|Confirm|File Operation Progress|Choose Files|Select a File).*$" },
        float  = true,
        center = true,
    })

    -- Floating utilities
    hl.window_rule({
        name   = "floating-utils",
        match  = { class = "^(org\\.pulseaudio\\.pavucontrol|pavucontrol|\\.blueman-manager-wrapped|blueman-manager|nm-connection-editor|com\\.gabm\\.satty|org\\.kde\\.polkit-kde-authentication-agent-1|hyprland-share-picker|xdg-desktop-portal-gtk)$" },
        float  = true,
        center = true,
    })

    hl.window_rule({
        name  = "pavucontrol-size",
        match = { class = "^(org\\.pulseaudio\\.pavucontrol|pavucontrol)$" },
        size  = "900 620",
    })
end

return M
