local home = os.getenv("HOME") or "/home/dyna"
package.path = home .. "/.config/hypr/lua/?.lua;" .. package.path

-- Reload Lua modules on hyprctl reload
for _, mod in ipairs({ "theme", "monitors", "look", "rules", "automation", "submaps", "binds" }) do
    package.loaded[mod] = nil
end

-------------------------------
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
-------------------
hl.on("hyprland.start", function()
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP HYPRLAND_INSTANCE_SIGNATURE")
    hl.exec_cmd("systemctl --user start nixos-fake-graphical-session.target")
    hl.exec_cmd("sh -c 'command -v theme-accent >/dev/null && theme-accent --init || true'")
    hl.exec_cmd("waybar")
    hl.exec_cmd("sh -c 'if command -v awww-daemon >/dev/null; then awww-daemon & sleep 0.5 && (awww img \"${HOME}/.cache/current-wallpaper\" 2>/dev/null || awww img \"${HOME}/backgrounds/main.png\"); else hyprpaper; fi'")
    hl.exec_cmd("swaync")
    hl.exec_cmd("swayosd-server")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)

-------------------
-------------------
require("theme").load_accent()
require("monitors").setup()
require("look").setup()
require("rules").setup()
require("automation").setup()
require("submaps").setup()
require("binds").setup()
