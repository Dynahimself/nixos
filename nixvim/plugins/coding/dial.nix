{ ... }:

{
  plugins.dial.enable = true;

  extraConfigLua = ''
    pcall(function()
      local augend = require("dial.augend")
      require("dial.config").augends:register_group({
        default = {
          augend.integer.alias.decimal_int,
          augend.integer.alias.hex,
          augend.date.alias["%Y-%m-%d"],
          augend.constant.alias.bool,
          augend.semver.alias.semver,
          augend.constant.new({ elements = { "and", "or" }, word = true, cyclic = true }),
          augend.constant.new({ elements = { "&&", "||" }, word = false, cyclic = true }),
          augend.constant.new({ elements = { "==", "!=" }, word = false, cyclic = true }),
          augend.constant.new({ elements = { "public", "private", "protected", "internal" }, word = true, cyclic = true }),
          augend.constant.new({ elements = { "const", "let", "var" }, word = true, cyclic = true }),
          augend.constant.new({ elements = { "true", "false" }, word = true, cyclic = true }),
          augend.constant.new({ elements = { "True", "False" }, word = true, cyclic = true }),
          augend.constant.new({ elements = { "enable", "disable" }, word = true, cyclic = true }),
        },
      })
    end)
  '';
}
