{ ... }:

{
  plugins = {
    glance = {
      enable = true;
      settings = {
        border = { enable = true; top_char = "─"; bottom_char = "─"; };
        theme.enable = true;
        mappings = {
          list = {
            e = "next";
            i = "previous";
            o = "jump";
            "<CR>" = "jump";
            q = "close";
            "<Esc>" = "close";
          };
          preview = {
            q = "close";
            "<Esc>" = "close";
          };
        };
      };
    };
  };
}
