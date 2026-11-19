{ ... }:

{
  # Colemak-DH (n=left, e=down, i=up, o=right) across terminal & reader apps

  programs.yazi.keymap.mgr.prepend_keymap = [
    { on = "n"; run = "leave"; desc = "Go back to parent directory"; }
    { on = "e"; run = "arrow 1"; desc = "Move cursor down"; }
    { on = "i"; run = "arrow -1"; desc = "Move cursor up"; }
    { on = "o"; run = "enter"; desc = "Enter child directory"; }
    { on = "k"; run = "find_arrow"; desc = "Next found"; }
    { on = "K"; run = "find_arrow --previous"; desc = "Previous found"; }
  ];

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

  xdg.configFile."lazygit/config.yml".source = ../dotfiles/configs/lazygit.yml;
  xdg.configFile."zellij/config.kdl".source = ../dotfiles/configs/zellij.kdl;
}
