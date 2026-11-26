{ ... }:

{
  plugins = {
    statuscol = {
      enable = true;
      settings = {
        relculright = true;
        segments.__raw = ''
          {
            { text = { require("statuscol.builtin").foldfunc }, click = "v:lua.ScFa" },
            { text = { "%s" }, click = "v:lua.ScSa" },
            { text = { require("statuscol.builtin").lnumfunc, " " }, condition = { true, require("statuscol.builtin").not_empty }, click = "v:lua.ScLa" },
          }
        '';
      };
    };
  };
}
