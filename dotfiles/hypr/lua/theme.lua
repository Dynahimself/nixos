-- Catppuccin Mocha dynamic theme engine (zero git-dirty accent persistence)
local M = {}

M.palette = {
    rosewater = "f5e0dc",
    flamingo  = "f2cdcd",
    pink      = "f5c2e7",
    mauve     = "cba6f7",
    red       = "f38ba8",
    maroon    = "eba0ac",
    peach     = "fab387",
    yellow    = "f9e2af",
    green     = "a6e3a1",
    teal      = "94e2d5",
    sky       = "89dceb",
    sapphire  = "74c7ec",
    blue      = "89b4fa",
    lavender  = "b4befe",
    text      = "cdd6f4",
    subtext1  = "bac2de",
    subtext0  = "a6adc8",
    overlay0  = "6c7086",
    surface2  = "585b70",
    surface1  = "45475a",
    surface0  = "313244",
    base      = "1e1e2e",
    mantle    = "181825",
    crust     = "11111b",
}

local home = os.getenv("HOME") or "/home/dyna"
local cache_dir = home .. "/.cache/mocha-theme"
local accent_file = cache_dir .. "/accent.json"

M.current = {
    name = "Mauve",
    primary = M.palette.mauve,
    secondary = M.palette.blue,
}

local function hex_to_rgb(hex)
    local r = tonumber(hex:sub(1, 2), 16) or 203
    local g = tonumber(hex:sub(3, 4), 16) or 166
    local b = tonumber(hex:sub(5, 6), 16) or 247
    return r, g, b
end

local function write_file(path, content)
    local f = io.open(path, "w")
    if f then
        f:write(content)
        f:close()
    end
end

function M.ensure_cache_files()
    os.execute("mkdir -p " .. cache_dir)
    local p = M.current.primary
    local s = M.current.secondary
    local r, g, b = hex_to_rgb(p)

    local f = io.open(cache_dir .. "/accent.css", "r")
    if f then
        f:close()
        return
    end

    write_file(accent_file, string.format(
        '{"name":"%s","primary":"#%s","secondary":"#%s"}\n',
        M.current.name, p, s
    ))
    write_file(cache_dir .. "/accent.css", string.format([[
@define-color accent       #%s;
@define-color accent_alt   #%s;
@define-color accent_soft  rgba(%d, %d, %d, 0.25);
@define-color accent_glow  rgba(%d, %d, %d, 0.40);
]], p, s, r, g, b, r, g, b))
    write_file(cache_dir .. "/accent.rasi", string.format([[
* {
    accent:     #%sff;
    accent-alt: #%sff;
}
]], p, s))
    write_file(cache_dir .. "/accent-hyprlock.conf", string.format([[
$accent = rgba(%sff)
$accentAlt = rgba(%sff)
]], p, s))
end

function M.load_accent()
    local f = io.open(accent_file, "r")
    if f then
        local content = f:read("*a") or ""
        f:close()
        local name = content:match('"name"%s*:%s*"([^"]+)"')
        local p = content:match('"primary"%s*:%s*"#?([0-9a-fA-F]+)"')
        local s = content:match('"secondary"%s*:%s*"#?([0-9a-fA-F]+)"')
        if p and #p == 6 then
            M.current.name = name or "Custom"
            M.current.primary = p:lower()
            M.current.secondary = (s and #s == 6) and s:lower() or M.palette.blue
        end
    end
    M.ensure_cache_files()
    return M.current
end

function M.apply_accent(primary, secondary)
    local p = (primary or M.current.primary):gsub("^#", ""):lower()
    local s = (secondary or M.current.secondary):gsub("^#", ""):lower()
    M.current.primary = p
    M.current.secondary = s

    hl.config({
        general = {
            col = {
                active_border   = { colors = { "rgba(" .. p .. "ff)", "rgba(" .. s .. "ff)" }, angle = 45 },
                inactive_border = "rgba(" .. M.palette.surface0 .. "cc)",
            },
        },
        decoration = {
            glow = {
                color          = "rgba(" .. p .. "55)",
                color_inactive = "rgba(" .. M.palette.crust .. "00)",
            },
        },
        group = {
            col = {
                border_active          = { colors = { "rgba(" .. p .. "ff)", "rgba(" .. s .. "ff)" }, angle = 45 },
                border_inactive        = "rgba(" .. M.palette.surface0 .. "cc)",
                border_locked_active   = { colors = { "rgba(" .. M.palette.peach .. "ff)", "rgba(" .. M.palette.red .. "ff)" }, angle = 45 },
                border_locked_inactive = "rgba(" .. M.palette.surface1 .. "cc)",
            },
            groupbar = {
                col = {
                    active          = "rgba(" .. p .. "e6)",
                    inactive        = "rgba(" .. M.palette.surface0 .. "cc)",
                    locked_active   = "rgba(" .. M.palette.peach .. "e6)",
                    locked_inactive = "rgba(" .. M.palette.surface1 .. "cc)",
                },
            },
        },
    })
end

function M.set_border_override(primary, secondary)
    if not primary then
        M.apply_accent(M.current.primary, M.current.secondary)
        return
    end
    local p = primary:gsub("^#", ""):lower()
    local s = (secondary or primary):gsub("^#", ""):lower()
    hl.config({
        general = {
            col = {
                active_border = { colors = { "rgba(" .. p .. "ff)", "rgba(" .. s .. "ff)" }, angle = 45 },
            },
        },
        decoration = {
            glow = {
                color = "rgba(" .. p .. "77)",
            },
        },
    })
end

return M
