-- Catppuccin Mocha Hyprland 0.57.2 Configuration

------------------
---- MONITORS ----
------------------
hl.monitor({ output = "DP-3", mode = "2560x1440@240", position = "0x0", scale = 1 })
hl.monitor({ output = "HDMI-A-1", mode = "1920x1080@144", position = "2560x0", scale = 1 })
hl.monitor({ output = "eDP-1", mode = "1920x1080@144", position = "0x0", scale = 1 })
hl.monitor({ output = "", mode = "highrr", position = "auto", scale = "auto" })

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

    binds = {
        allow_workspace_cycles = true,
    },

    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo = true,
        disable_splash_rendering = true,
        key_press_enables_dpms = true,
        mouse_move_enables_dpms = true,
        enable_swallow = true,
        swallow_regex = "^(ghostty|com\\.mitchellh\\.ghostty)$",
    },

    input = {
        kb_layout = "us",
        kb_variant = "",
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
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesIn",  enabled = true,  speed = 1.21, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "workspacesOut", enabled = true,  speed = 1.94, bezier = "almostLinear", style = "fade" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })

-- Scratchpad workspace auto-spawns a Ghostty terminal when opened empty
hl.workspace_rule({
    workspace = "special:scratchpad",
    on_created_empty = "ghostty",
})

---------------------
---- KEYBINDINGS ----
---------------------
local mainMod = "SUPER"

-- Core workflow actions
hl.bind(mainMod .. " + RETURN",        hl.dsp.exec_cmd("ghostty"),                                                     { desc = "Open Terminal (Ghostty)" })
hl.bind(mainMod .. " + Q",             hl.dsp.window.close(),                                                          { desc = "Close Active Window" })
hl.bind(mainMod .. " + M",             hl.dsp.exit(),                                                                  { desc = "Exit Hyprland Session" })
hl.bind(mainMod .. " + E",             hl.dsp.exec_cmd("dolphin"),                                                     { desc = "Open File Manager (Dolphin)" })
hl.bind(mainMod .. " + T",             hl.dsp.window.float({ action = "toggle" }),                                     { desc = "Toggle Floating Window" })
hl.bind(mainMod .. " + F",             hl.dsp.window.fullscreen(),                                                     { desc = "Toggle Fullscreen" })
hl.bind(mainMod .. " + J",             hl.dsp.layout("togglesplit"),                                                   { desc = "Toggle Split Direction" })
hl.bind(mainMod .. " + P",             hl.dsp.window.pin(),                                                            { desc = "Pin Floating Window" })
hl.bind(mainMod .. " + CTRL + RETURN", hl.dsp.exec_cmd("rofi -show drun"),                                             { desc = "App Launcher (Rofi)" })
hl.bind(mainMod .. " + B",             hl.dsp.exec_cmd("zen"),                                                         { desc = "Open Browser (Zen)" })
hl.bind(mainMod .. " + SHIFT + B",     hl.dsp.exec_cmd("sh -c 'pkill -x waybar; pkill -x .waybar-wrapped; sleep 0.2; nohup setsid waybar >/tmp/waybar.log 2>&1 </dev/null &'"), { desc = "Restart Waybar" })
hl.bind(mainMod .. " + SHIFT + W",     hl.dsp.exec_cmd("rofi-wallpaper"),                                              { desc = "Wallpaper Switcher" })
hl.bind(mainMod .. " + G",             hl.dsp.exec_cmd("sh -c 'if hyprctl getoption input:kb_variant | grep -q colemak_dh; then hyprctl eval \"hl.config({ input = { kb_variant = \\\"\\\" } })\" >/dev/null && notify-send \"Keyboard\" \"Switched to QWERTY\"; else hyprctl eval \"hl.config({ input = { kb_variant = \\\"colemak_dh\\\" } })\" >/dev/null && notify-send \"Keyboard\" \"Switched to Colemak-DH\"; fi'"), { desc = "Toggle QWERTY / Colemak-DH" })
hl.bind("Print",                       hl.dsp.exec_cmd("hyprshot -m region"),                                          { desc = "Screenshot Region" })

-- Fleet, Workbench, System & QoL binds
hl.bind(mainMod .. " + A",             hl.dsp.exec_cmd("rofi-fleet"),                                                  { desc = "Fleet & Homelab Menu" })
hl.bind(mainMod .. " + D",             hl.dsp.exec_cmd("rofi-workbench"),                                              { desc = "Desktop Workbench & Project Hub" })
hl.bind(mainMod .. " + I",             hl.dsp.exec_cmd("rofi-system"),                                                 { desc = "System Control Center" })
hl.bind(mainMod .. " + O",             hl.dsp.exec_cmd("rofi-audio"),                                                  { desc = "Audio Output Switcher" })
hl.bind(mainMod .. " + W",             hl.dsp.exec_cmd("rofi-wifi"),                                                   { desc = "Network & Tailscale Menu" })
hl.bind(mainMod .. " + slash",         hl.dsp.exec_cmd("rofi-binds"),                                                  { desc = "Command Palette & Keybinds" })
hl.bind(mainMod .. " + V",             hl.dsp.exec_cmd("rofi-clip"),                                                   { desc = "Clipboard History" })
hl.bind(mainMod .. " + C",             hl.dsp.exec_cmd("rofi-calc"),                                                   { desc = "Calculator (Rofi)" })
hl.bind(mainMod .. " + S",             hl.dsp.workspace.toggle_special("scratchpad"),                                  { desc = "Toggle Scratchpad Terminal" })
hl.bind(mainMod .. " + ALT + S",       hl.dsp.window.move({ workspace = "special:scratchpad" }),                       { desc = "Send Window to Scratchpad" })
hl.bind(mainMod .. " + N",             hl.dsp.exec_cmd("quick-note"),                                                  { desc = "Quick Note -> CS Hub" })
hl.bind(mainMod .. " + SHIFT + N",     hl.dsp.exec_cmd("swaync-client -t -sw"),                                        { desc = "Notification Center" })
hl.bind(mainMod .. " + L",             hl.dsp.exec_cmd("hyprlock"),                                                    { desc = "Lock Screen" })
hl.bind(mainMod .. " + SHIFT + I",     hl.dsp.exec_cmd("rofi-wallpaper"),                                              { desc = "Wallpaper Switcher" })
hl.bind(mainMod .. " + SHIFT + P",     hl.dsp.exec_cmd("wlogout -b 5 -p layer-shell"),                                 { desc = "Power Menu (wlogout)" })
hl.bind(mainMod .. " + SHIFT + T",     hl.dsp.exec_cmd("cshub-term-capture"),                                          { desc = "Capture CS Hub Term" })
hl.bind(mainMod .. " + SHIFT + S",     hl.dsp.exec_cmd("sh -c 'if command -v satty >/dev/null; then grim -g \"$(slurp)\" - | satty -f -; else hyprshot -m region; fi'"), { desc = "Screenshot Region -> Annotate" })
hl.bind(mainMod .. " + F1",            hl.dsp.exec_cmd("study-mode"),                                                  { desc = "Toggle Study Mode" })
hl.bind(mainMod .. " + F2",            hl.dsp.exec_cmd("game-mode"),                                                   { desc = "Toggle Gaming Mode" })

-- Focus, Window Move, Resize & Monitor Navigation
hl.bind(mainMod .. " + left",          hl.dsp.focus({ direction = "left" }),                                           { desc = "Focus Left" })
hl.bind(mainMod .. " + right",         hl.dsp.focus({ direction = "right" }),                                          { desc = "Focus Right" })
hl.bind(mainMod .. " + up",            hl.dsp.focus({ direction = "up" }),                                             { desc = "Focus Up" })
hl.bind(mainMod .. " + down",          hl.dsp.focus({ direction = "down" }),                                           { desc = "Focus Down" })

hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }),                                     { desc = "Move Window Left" })
hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }),                                    { desc = "Move Window Right" })
hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }),                                       { desc = "Move Window Up" })
hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }),                                     { desc = "Move Window Down" })

hl.bind(mainMod .. " + CTRL + left",   hl.dsp.window.resize({ x = -40, y = 0 }),                                       { repeating = true, desc = "Resize Narrower" })
hl.bind(mainMod .. " + CTRL + right",  hl.dsp.window.resize({ x = 40, y = 0 }),                                        { repeating = true, desc = "Resize Wider" })
hl.bind(mainMod .. " + CTRL + up",     hl.dsp.window.resize({ x = 0, y = -40 }),                                       { repeating = true, desc = "Resize Shorter" })
hl.bind(mainMod .. " + CTRL + down",   hl.dsp.window.resize({ x = 0, y = 40 }),                                        { repeating = true, desc = "Resize Taller" })

hl.bind(mainMod .. " + TAB",           hl.dsp.focus({ workspace = "previous" }),                                       { desc = "Previous Workspace" })
hl.bind(mainMod .. " + period",        hl.dsp.workspace.swap_monitors({ monitor1 = "DP-3", monitor2 = "HDMI-A-1" }),   { desc = "Swap Monitors (DP-3 <-> HDMI-A-1)" })

-- Workspaces 1..10 & Move window 1..10
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }),       { desc = "Workspace " .. i })
    hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }), { desc = "Move Window to WS " .. i })
end

-- Mouse workspace scroll + drag/resize
hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }), { desc = "Next Workspace (Scroll)" })
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }), { desc = "Prev Workspace (Scroll)" })
hl.bind(mainMod .. " + mouse:272",  hl.dsp.window.drag(),   { mouse = true, desc = "Drag Window" })
hl.bind(mainMod .. " + mouse:273",  hl.dsp.window.resize(), { mouse = true, desc = "Resize Window" })

-- Hardware / media keys
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("sh -c 'command -v swayosd-client >/dev/null && swayosd-client --output-volume raise || wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%+'"), { locked = true, repeating = true, desc = "Volume Up" })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("sh -c 'command -v swayosd-client >/dev/null && swayosd-client --output-volume lower || wpctl set-volume -l 1.4 @DEFAULT_AUDIO_SINK@ 5%-'"), { locked = true, repeating = true, desc = "Volume Down" })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("sh -c 'command -v swayosd-client >/dev/null && swayosd-client --brightness raise || brightnessctl set 10%+'"), { locked = true, repeating = true, desc = "Brightness Up" })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("sh -c 'command -v swayosd-client >/dev/null && swayosd-client --brightness lower || brightnessctl set 10%-'"), { locked = true, repeating = true, desc = "Brightness Down" })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("sh -c 'command -v swayosd-client >/dev/null && swayosd-client --output-volume mute-toggle || wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle'"), { locked = true, desc = "Mute Output" })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("sh -c 'command -v swayosd-client >/dev/null && swayosd-client --input-volume mute-toggle || wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle'"), { locked = true, desc = "Mute Mic" })
hl.bind("XF86AudioPlay",         hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, desc = "Play / Pause Media" })
hl.bind("XF86AudioPause",        hl.dsp.exec_cmd("playerctl play-pause"), { locked = true, desc = "Play / Pause Media" })
hl.bind("XF86AudioNext",         hl.dsp.exec_cmd("playerctl next"),       { locked = true, desc = "Next Track" })
hl.bind("XF86AudioPrev",         hl.dsp.exec_cmd("playerctl previous"),   { locked = true, desc = "Previous Track" })
hl.bind("XF86WLAN",              hl.dsp.exec_cmd("nmcli radio wifi toggle"), { desc = "Toggle Wi-Fi" })

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
    name = "pip-float-pin",
    match = { title = "^(Picture-in-Picture)$" },
    float = true,
    pin = true,
    size = "640 360",
})

hl.window_rule({
    name = "floating-dialogs",
    match = { title = "^(Open File|Save File|Save As|Confirm|File Operation Progress).*$" },
    float = true,
})

hl.window_rule({
    name = "floating-utils",
    match = { class = "^(org\\.pulseaudio\\.pavucontrol|pavucontrol|\\.blueman-manager-wrapped|blueman-manager|nm-connection-editor|com\\.gabm\\.satty|org\\.kde\\.polkit-kde-authentication-agent-1)$" },
    float = true,
})
