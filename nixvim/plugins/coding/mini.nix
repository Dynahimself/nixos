{ ... }:

{
  plugins = {
    mini = {
      enable = true;
      modules = {
        ai = {
          n_lines = 500;
          mappings = {
            around = "a";
            inside = "l";
            around_next = "an";
            inside_next = "ln";
            around_last = "ap";
            inside_last = "lp";
          };
        };
        surround = {
          mappings = {
            add = "gsa";
            delete = "gsd";
            find = "gsf";
            find_left = "gsF";
            highlight = "gsh";
            replace = "gsr";
            update_n_lines = "gsn";
          };
        };
        pairs = { };
        icons = { };
        hipatterns = { };
      };
    };
  };

  extraConfigLua = ''
    -- Alias mini.icons as nvim-web-devicons
    pcall(function() require("mini.icons").mock_nvim_web_devicons() end)
  '';
}
