-- Catppuccin Mocha Hyprland 0.57.2 Configuration (translated cleanly from conf/*.conf)

------------------
---- MONITORS ----
------------------
hl.monitor({ output = "eDP-1", mode = "1920x1080@144", position = "0x0", scale = 1 })
hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })

-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------
hl.env("XDG_CURRENT_DESKTOP", "Hyprland")
hl.env("XDG_SESSION_TYPE", "wayland")
hl.env("XDG_SESSION_DESKTOP", "Hyprland")
hl.env("QT_QPA_PLATFORM", "wayland;xcb")
hl.env("QT_QPA_PLATFORMTHEME", "qt6ct")
hl.env("QT_WAYLAND_DISABLE_WINDOWDECORATION", "1")
hl.env("QT_AUTO_SCREEN_SCALE_FACTOR", "1")
hl.env("GDK_SCALE", "1")
hl.env("MOZ_ENABLE_WAYLAND", "1")
hl.env("XCURSOR_THEME", "catppuccin-mocha-dark-cursors")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")
hl.env("APPIMAGELAUNCHER_DISABLE", "1")
hl.env("OZONE_PLATFORM", "wayland")

-------------------
---- AUTOSTART ----
-------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")
    hl.exec_cmd("systemctl --user start nixos-fake-graphical-session.target")
    hl.exec_cmd("waybar")
    hl.exec_cmd("sh -c 'if command -v awww-daemon >/dev/null; then awww-daemon & sleep 0.5 && (awww img \"${HOME}/.cache/current-wallpaper\" 2>/dev/null || awww img \"${HOME}/backgrounds/main.png\"); else hyprpaper; fi'")
    hl.exec_cmd("swaync")
    hl.exec_cmd("swayosd-server")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("nm-applet --indicator")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

-----------------------
---- LOOK AND FEEL ----
-----------------------
hl.config({
    general = {
        gaps_in = 5,
        gaps_out = 10,
        border_size = 2,
        col = {
            active_border = { colors = { "rgba(cba6f7ff)", "rgba(89b4faff)" }, angle = 45 },
            inactive_border = "rgba(313244cc)",
        },
        layout = "dwindle",
        resize_on_border = true,
    },

    decoration = {
        rounding = 12,
        rounding_power = 2,
        active_opacity = 1.0,
        inactive_opacity = 0.97,
        blur = {
            enabled = true,
            size = 6,
            passes = 2,
            vibrancy = 0.17,
        },
        shadow = {
            enabled = true,
            range = 14,
            render_power = 3,
            color = 0xcc11111b,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        enable_swallow = true,
        swallow_regex = "^(ghostty|com\\.mitchellh\\.ghostty)$",
    },

    input = {
        kb_layout = "us",
        kb_variant = "colemak_dh",
        follow_mouse = 1,
        sensitivity = 0,
        touchpad = {
            natural_scroll = false,
        },
    },
})

-- Animations & curves
hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })
hl.curve("easy",           { type = "spring", mass = 1, stiffness = 238.1191, damping = 24.21279333 })

hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear", style = "slide" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "almostLinear", style = "slide" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "slide" })

hl.gesture({ fingers = 3, direction = "horizontal", action = "workspace" })

---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"

-- Core workflow actions (all original binds preserved)
hl.bind(mainMod .. " + RETURN",        hl.dsp.exec_cmd("ghostty"))
hl.bind(mainMod .. " + Q",             hl.dsp.window.close())
hl.bind(mainMod .. " + M",             hl.dsp.exec_cmd("hyprctl dispatch 'hl.dsp.exit()'"))
hl.bind(mainMod .. " + E",             hl.dsp.exec_cmd("dolphin"))
hl.bind(mainMod .. " + T",             hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F",             hl.dsp.exec_cmd("hyprctl dispatch fullscreen"))
hl.bind(mainMod .. " + CTRL + RETURN", hl.dsp.exec_cmd("rofi -show drun"))
hl.bind(mainMod .. " + B",             hl.dsp.exec_cmd("zen"))
hl.bind(mainMod .. " + SHIFT + B",     hl.dsp.exec_cmd("sh -c 'pkill -x waybar; pkill -x .waybar-wrapped; sleep 0.2; nohup setsid waybar >/tmp/waybar.log 2>&1 </dev/null &'"))
hl.bind(mainMod .. " + SHIFT + W",     hl.dsp.exec_cmd("rofi-wallpaper"))
hl.bind(mainMod .. " + G",             hl.dsp.exec_cmd("sh -c 'hyprctl getoption input:kb_variant | grep -q colemak_dh && hyprctl eval \"hl.config({ input = { kb_variant = \\\"\\\" } })\" || hyprctl eval \"hl.config({ input = { kb_variant = \\\"colemak_dh\\\" } })\"'"))
hl.bind("Print",                       hl.dsp.exec_cmd("hyprshot -m region"))

-- Fleet, System & QoL binds
hl.bind(mainMod .. " + A",             hl.dsp.exec_cmd("rofi-fleet"))
hl.bind(mainMod .. " + I",             hl.dsp.exec_cmd("rofi-system"))
hl.bind(mainMod .. " + W",             hl.dsp.exec_cmd("rofi-wifi"))
hl.bind(mainMod .. " + slash",         hl.dsp.exec_cmd("rofi-binds"))
hl.bind(mainMod .. " + V",             hl.dsp.exec_cmd("sh -c 'cliphist list | rofi -dmenu -p \"󰅌 Clipboard\" | cliphist decode | wl-copy'"))
hl.bind(mainMod .. " + C",             hl.dsp.exec_cmd("rofi -show calc -modi calc -no-show-match -no-sort -p '󰃬 Calc'"))
hl.bind(mainMod .. " + S",             hl.dsp.exec_cmd("sh -c 'hyprctl clients -j | jq -e \".[] | select(.workspace.name == \\\"special:scratchpad\\\")\" >/dev/null || (nohup setsid ghostty >/dev/null 2>&1 </dev/null & sleep 0.3); hyprctl dispatch togglespecialworkspace scratchpad'"))
hl.bind(mainMod .. " + N",             hl.dsp.exec_cmd("quick-note"))
hl.bind(mainMod .. " + SHIFT + N",     hl.dsp.exec_cmd("swaync-client -t -sw"))
hl.bind(mainMod .. " + L",             hl.dsp.exec_cmd("hyprlock"))
hl.bind(mainMod .. " + SHIFT + I",     hl.dsp.exec_cmd("rofi-wallpaper"))
hl.bind(mainMod .. " + SHIFT + P",     hl.dsp.exec_cmd("wlogout -p layer-shell"))
hl.bind(mainMod .. " + SHIFT + T",     hl.dsp.exec_cmd("cshub-term-capture"))
hl.bind(mainMod .. " + SHIFT + S",     hl.dsp.exec_cmd("sh -c 'if command -v satty >/dev/null; then grim -g \"$(slurp)\" - | satty -f -; else hyprshot -m region; fi'"))
hl.bind(mainMod .. " + F1",            hl.dsp.exec_cmd("study-mode"))
hl.bind(mainMod .. " + F2",            hl.dsp.exec_cmd("game-mode"))

-- Focus (arrows)
hl.bind(mainMod .. " + left",  hl.dsp.focus({ direction = "left" }))
hl.bind(mainMod .. " + right", hl.dsp.focus({ direction = "right" }))
hl.bind(mainMod .. " + up",    hl.dsp.focus({ direction = "up" }))
hl.bind(mainMod .. " + down",  hl.dsp.focus({ direction = "down" }))

-- Workspaces 1..10 & Move window 1..10
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Mouse workspace scroll + drag/resize
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))
hl.bind(mainMod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true })

-- Hardware / media keys
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("sh -c 'command -v swayosd-client >/dev/null && swayosd-client --output-volume raise || wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+'"), { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("sh -c 'command -v swayosd-client >/dev/null && swayosd-client --output-volume lower || wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-'"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("sh -c 'command -v swayosd-client >/dev/null && swayosd-client --brightness raise || brightnessctl set 10%+'"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("sh -c 'command -v swayosd-client >/dev/null && swayosd-client --brightness lower || brightnessctl set 10%-'"), { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("sh -c 'command -v swayosd-client >/dev/null && swayosd-client --output-volume mute-toggle || wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle'"), { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("sh -c 'command -v swayosd-client >/dev/null && swayosd-client --input-volume mute-toggle || wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle'"), { locked = true })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPause",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),   { locked = true })
hl.bind("XF86WLAN",              hl.dsp.exec_cmd("nmcli radio wifi toggle"))

----------------------
---- WINDOW RULES ----
----------------------
hl.window_rule({
    name = "suppress-maximize-events",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name = "fix-xwayland-drags",
    match = {
        class = "^$",
        title = "^$",
        xwayland = true,
        float = true,
        fullscreen = false,
        pin = false,
    },
    no_focus = true,
})

hl.window_rule({ name = "steam-tile",         match = { class = "^(steam)$" }, tile = true })
hl.window_rule({ name = "steam-friends-float",match = { class = "^(steam)$", title = "^(Friends List)$" }, float = true })
hl.window_rule({ name = "steam-news-float",   match = { class = "^(steam)$", title = "^(.*- News.*)$" }, float = true })

hl.window_rule({ name = "study-ws4",  match = { class = "^(anki|org\\.pwmt\\.zathura|sioyek)$" }, workspace = 4 })
hl.window_rule({ name = "social-ws5", match = { class = "^(discord|vesktop|Spotify)$" }, workspace = 5 })

hl.window_rule({
    name = "floating-utils",
    match = { class = "^(org\\.pulseaudio\\.pavucontrol|pavucontrol|\\.blueman-manager-wrapped|blueman-manager|nm-connection-editor|com\\.gabm\\.satty)$" },
    float = true,
})
