{ ... }:

{
  plugins = {
    tiny-inline-diagnostic = {
      enable = true;
      settings = {
        preset = "modern";
        transparent_bg = false;
        options = {
          show_source.enabled = true;
          multilines = {
            enabled = true;
            always_show = false;
          };
          show_all_diags_on_cursorline = true;
          throttle = 40;
        };
      };
    };
  };
}
