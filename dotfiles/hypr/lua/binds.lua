-- Keybindings (preserves all existing muscle memory + adds Colemak-DH, submaps, scratchpads & power tools)
local auto = require("automation")
local M = {}

function M.setup()
    local mainMod = "SUPER"

    -- Core workflow actions
    hl.bind(mainMod .. " + RETURN",        hl.dsp.exec_cmd("ghostty"),                                                     { desc = "Open Terminal (Ghostty)" })
    hl.bind(mainMod .. " + Q",             hl.dsp.window.close(),                                                          { desc = "Close Active Window" })
    hl.bind(mainMod .. " + M",             hl.dsp.exit(),                                                                  { desc = "Exit Hyprland Session" })
    hl.bind(mainMod .. " + E",             hl.dsp.exec_cmd("dolphin"),                                                     { desc = "Open File Manager (Dolphin)" })
    hl.bind(mainMod .. " + T",             hl.dsp.window.float({ action = "toggle" }),                                     { desc = "Toggle Floating Window" })
    hl.bind(mainMod .. " + ALT + F",       function() auto.float_center_focus() end,                                       { desc = "Float & Center Window (70%)" })
    hl.bind(mainMod .. " + ALT + O",       function() auto.toggle_opaque() end,                                            { desc = "Toggle Active Window Opaque" })
    hl.bind(mainMod .. " + F",             hl.dsp.window.fullscreen(),                                                     { desc = "Toggle Fullscreen" })
    hl.bind(mainMod .. " + J",             hl.dsp.layout("togglesplit"),                                                   { desc = "Toggle Split Direction" })
    hl.bind(mainMod .. " + P",             hl.dsp.window.pin(),                                                            { desc = "Pin Floating Window" })
    hl.bind(mainMod .. " + CTRL + RETURN", hl.dsp.exec_cmd("rofi -show drun"),                                             { desc = "App Launcher (Rofi)" })
    hl.bind(mainMod .. " + SHIFT + TAB",   hl.dsp.exec_cmd("rofi -show window"),                                           { desc = "Window Switcher (Rofi)" })
    hl.bind(mainMod .. " + B",             hl.dsp.exec_cmd("zen"),                                                         { desc = "Open Browser (Zen)" })
    hl.bind(mainMod .. " + SHIFT + B",     hl.dsp.exec_cmd("sh -c 'pkill -x waybar; pkill -x .waybar-wrapped; sleep 0.2; nohup setsid waybar >/tmp/waybar.log 2>&1 </dev/null &'"), { desc = "Restart Waybar" })
    hl.bind(mainMod .. " + SHIFT + W",     hl.dsp.exec_cmd("rofi-wallpaper"),                                              { desc = "Wallpaper Switcher" })
    hl.bind(mainMod .. " + G",             function() auto.toggle_colemak() end,                                           { desc = "Toggle QWERTY / Colemak-DH" })
    hl.bind("Print",                       hl.dsp.exec_cmd("hyprshot -m region"),                                          { desc = "Screenshot Region" })

    -- Modal submaps (Colemak-DH native)
    hl.bind(mainMod .. " + R",             hl.dsp.submap("resize"),                                                        { desc = "Enter Resize Mode (Submap)" })
    hl.bind(mainMod .. " + SHIFT + G",     hl.dsp.submap("group"),                                                         { desc = "Enter Group/Tab Mode (Submap)" })
    hl.bind(mainMod .. " + Z",             hl.dsp.submap("layout"),                                                        { desc = "Enter Layout/Zoom Mode (Submap)" })
    hl.bind(mainMod .. " + bracketleft",   hl.dsp.group.prev(),                                                            { desc = "Previous Group Tab" })
    hl.bind(mainMod .. " + bracketright",  hl.dsp.group.next(),                                                            { desc = "Next Group Tab" })

    -- Smooth compositor zoom
    hl.bind(mainMod .. " + equal",         function() auto.zoom_delta(0.35) end,                                           { repeating = true, desc = "Zoom In (Compositor)" })
    hl.bind(mainMod .. " + minus",         function() auto.zoom_delta(-0.35) end,                                          { repeating = true, desc = "Zoom Out (Compositor)" })
    hl.bind(mainMod .. " + BackSpace",     function() auto.zoom_reset() end,                                               { desc = "Reset Zoom (Compositor)" })

    -- Fleet, Workbench, System & QoL hubs
    hl.bind(mainMod .. " + A",             hl.dsp.exec_cmd("rofi-fleet"),                                                  { desc = "Fleet & Homelab Menu" })
    hl.bind(mainMod .. " + D",             hl.dsp.exec_cmd("rofi-workbench"),                                              { desc = "Desktop Workbench & Project Hub" })
    hl.bind(mainMod .. " + I",             hl.dsp.exec_cmd("rofi-system"),                                                 { desc = "System Control Center" })
    hl.bind(mainMod .. " + O",             hl.dsp.exec_cmd("rofi-audio"),                                                  { desc = "Audio & Mic Switcher" })
    hl.bind(mainMod .. " + W",             hl.dsp.exec_cmd("rofi-wifi"),                                                   { desc = "Network & Tailscale Menu" })
    hl.bind(mainMod .. " + slash",         hl.dsp.exec_cmd("rofi-binds"),                                                  { desc = "Command Palette & Keybinds" })
    hl.bind(mainMod .. " + V",             hl.dsp.exec_cmd("rofi-clip"),                                                   { desc = "Clipboard History" })
    hl.bind(mainMod .. " + C",             hl.dsp.exec_cmd("rofi-calc"),                                                   { desc = "Calculator (Rofi)" })
    hl.bind(mainMod .. " + N",             hl.dsp.exec_cmd("quick-note"),                                                  { desc = "Quick Note -> CS Hub" })
    hl.bind(mainMod .. " + SHIFT + N",     hl.dsp.exec_cmd("swaync-client -t -sw"),                                        { desc = "Notification Center" })
    hl.bind(mainMod .. " + L",             hl.dsp.exec_cmd("hyprlock"),                                                    { desc = "Lock Screen" })
    hl.bind(mainMod .. " + SHIFT + I",     hl.dsp.exec_cmd("rofi-wallpaper"),                                              { desc = "Wallpaper Switcher" })
    hl.bind(mainMod .. " + SHIFT + P",     hl.dsp.exec_cmd("wlogout -b 5 -p layer-shell"),                                 { desc = "Power Menu (wlogout)" })
    hl.bind(mainMod .. " + SHIFT + T",     hl.dsp.exec_cmd("cshub-term-capture"),                                          { desc = "Capture CS Hub Term" })
    hl.bind(mainMod .. " + SHIFT + S",     hl.dsp.exec_cmd("sh -c 'if command -v satty >/dev/null; then grim -g \"$(slurp)\" - | satty -f -; else hyprshot -m region; fi'"), { desc = "Screenshot Region -> Annotate" })
    hl.bind(mainMod .. " + SHIFT + C",     hl.dsp.exec_cmd("sh -c 'if command -v hyprpicker >/dev/null; then c=$(hyprpicker -a -n); [ -n \"$c\" ] && notify-send \"Color Picker\" \"Copied $c\"; else notify-send \"Color Picker\" \"Rebuild needed for hyprpicker\"; fi'"), { desc = "Color Picker -> Clipboard" })
    hl.bind(mainMod .. " + SHIFT + O",     hl.dsp.exec_cmd("sh -c 'txt=$(grim -g \"$(slurp)\" - | tesseract - - -l eng+fra 2>/dev/null); [ -n \"$txt\" ] && printf \"%s\" \"$txt\" | wl-copy && notify-send \"OCR Copied\" \"$(printf \"%s\" \"$txt\" | head -c 100)\"'"), { desc = "OCR Region -> Clipboard" })
    hl.bind(mainMod .. " + SHIFT + R",     hl.dsp.exec_cmd("sh -c 'if pgrep -x wf-recorder >/dev/null; then pkill -INT -x wf-recorder && notify-send \"Recorder\" \"Saved to ~/Videos/\"; else mkdir -p \"$HOME/Videos\"; f=\"$HOME/Videos/rec_$(date +%Y%m%d_%H%M%S).mp4\"; nohup setsid wf-recorder -g \"$(slurp)\" -f \"$f\" >/dev/null 2>&1 </dev/null & notify-send \"Recorder\" \"Recording -> $f\"; fi'"), { desc = "Toggle Screen Recording" })
    hl.bind(mainMod .. " + F1",            hl.dsp.exec_cmd("study-mode"),                                                  { desc = "Toggle Study Mode" })
    hl.bind(mainMod .. " + F2",            hl.dsp.exec_cmd("game-mode"),                                                   { desc = "Toggle Gaming Mode" })

    -- Scratchpad workspaces
    hl.bind(mainMod .. " + S",             hl.dsp.workspace.toggle_special("scratchpad"),                                  { desc = "Toggle Scratchpad Terminal" })
    hl.bind(mainMod .. " + ALT + S",       hl.dsp.window.move({ workspace = "special:scratchpad" }),                       { desc = "Send Window to Scratchpad" })
    hl.bind(mainMod .. " + ALT + N",       hl.dsp.workspace.toggle_special("notes"),                                       { desc = "Toggle Notes Scratchpad (Nvim)" })
    hl.bind(mainMod .. " + ALT + B",       hl.dsp.workspace.toggle_special("monitor"),                                     { desc = "Toggle System Monitor Scratchpad" })
    hl.bind(mainMod .. " + ALT + M",       hl.dsp.workspace.toggle_special("music"),                                       { desc = "Toggle Music Scratchpad" })

    -- Focus, Window Move & Resize (Arrow keys + Colemak-DH SUPER+CTRL+n/e/i/o)
    hl.bind(mainMod .. " + left",          hl.dsp.focus({ direction = "left" }),                                           { desc = "Focus Left" })
    hl.bind(mainMod .. " + right",         hl.dsp.focus({ direction = "right" }),                                          { desc = "Focus Right" })
    hl.bind(mainMod .. " + up",            hl.dsp.focus({ direction = "up" }),                                             { desc = "Focus Up" })
    hl.bind(mainMod .. " + down",          hl.dsp.focus({ direction = "down" }),                                           { desc = "Focus Down" })

    hl.bind(mainMod .. " + SHIFT + left",  hl.dsp.window.move({ direction = "left" }),                                     { desc = "Move Window Left" })
    hl.bind(mainMod .. " + SHIFT + right", hl.dsp.window.move({ direction = "right" }),                                    { desc = "Move Window Right" })
    hl.bind(mainMod .. " + SHIFT + up",    hl.dsp.window.move({ direction = "up" }),                                       { desc = "Move Window Up" })
    hl.bind(mainMod .. " + SHIFT + down",  hl.dsp.window.move({ direction = "down" }),                                     { desc = "Move Window Down" })

    -- Colemak-DH home-row focus & move (SUPER + CTRL + n/e/i/o)
    hl.bind(mainMod .. " + CTRL + n",         hl.dsp.focus({ direction = "left" }),                                        { desc = "Focus Left (Colemak)" })
    hl.bind(mainMod .. " + CTRL + e",         hl.dsp.focus({ direction = "down" }),                                        { desc = "Focus Down (Colemak)" })
    hl.bind(mainMod .. " + CTRL + i",         hl.dsp.focus({ direction = "up" }),                                          { desc = "Focus Up (Colemak)" })
    hl.bind(mainMod .. " + CTRL + o",         hl.dsp.focus({ direction = "right" }),                                       { desc = "Focus Right (Colemak)" })
    hl.bind(mainMod .. " + CTRL + SHIFT + n", hl.dsp.window.move({ direction = "left" }),                                  { desc = "Move Left (Colemak)" })
    hl.bind(mainMod .. " + CTRL + SHIFT + e", hl.dsp.window.move({ direction = "down" }),                                  { desc = "Move Down (Colemak)" })
    hl.bind(mainMod .. " + CTRL + SHIFT + i", hl.dsp.window.move({ direction = "up" }),                                    { desc = "Move Up (Colemak)" })
    hl.bind(mainMod .. " + CTRL + SHIFT + o", hl.dsp.window.move({ direction = "right" }),                                 { desc = "Move Right (Colemak)" })

    hl.bind(mainMod .. " + CTRL + left",   hl.dsp.window.resize({ x = -40, y = 0 }),                                       { repeating = true, desc = "Resize Narrower" })
    hl.bind(mainMod .. " + CTRL + right",  hl.dsp.window.resize({ x = 40, y = 0 }),                                        { repeating = true, desc = "Resize Wider" })
    hl.bind(mainMod .. " + CTRL + up",     hl.dsp.window.resize({ x = 0, y = -40 }),                                       { repeating = true, desc = "Resize Shorter" })
    hl.bind(mainMod .. " + CTRL + down",   hl.dsp.window.resize({ x = 0, y = 40 }),                                        { repeating = true, desc = "Resize Taller" })

    hl.bind(mainMod .. " + TAB",            hl.dsp.focus({ workspace = "previous" }),                                      { desc = "Previous Workspace" })
    hl.bind(mainMod .. " + period",         hl.dsp.workspace.swap_monitors({ monitor1 = "DP-3", monitor2 = "HDMI-A-1" }),  { desc = "Swap Monitors (DP-3 <-> HDMI-A-1)" })
    hl.bind(mainMod .. " + SHIFT + period", function() auto.throw_to_other_monitor() end,                                  { desc = "Throw Window to Other Monitor" })

    -- Workspaces 1..10: switch, move, silent move
    for i = 1, 10 do
        local key = i % 10
        hl.bind(mainMod .. " + " .. key,         hl.dsp.focus({ workspace = i }),                      { desc = "Workspace " .. i })
        hl.bind(mainMod .. " + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }),                { desc = "Move Window to WS " .. i })
        hl.bind(mainMod .. " + ALT + " .. key,   hl.dsp.window.move({ workspace = i, silent = true }), { desc = "Silently Move Window to WS " .. i })
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
end

return M
