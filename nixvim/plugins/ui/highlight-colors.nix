{ ... }:

{
  plugins = {
    highlight-colors = {
      enable = true;
      settings = {
        render = "virtual";
        virtual_symbol = "■";
        enable_hex = true;
        enable_short_hex = true;
        enable_rgb = true;
        enable_hsl = true;
        enable_named_colors = true;
        enable_tailwind = true;
      };
    };
  };
}
