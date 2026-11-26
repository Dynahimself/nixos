{ ... }:

{
  programs.zathura = {
    enable = true;
    options = {
      selection-clipboard = "clipboard";
      recolor = true;
      default-bg = "#1e1e2e";
      default-fg = "#cdd6f4";
      statusbar-bg = "#181825";
      statusbar-fg = "#cdd6f4";
      inputbar-bg = "#181825";
      inputbar-fg = "#cba6f7";
      recolor-lightcolor = "#1e1e2e";
      recolor-darkcolor = "#cdd6f4";
    };
    mappings = {
      n = "scroll left";
      e = "scroll down";
      i = "scroll up";
      o = "scroll right";
      J = "navigate next";
      K = "navigate previous";
    };
  };
}
