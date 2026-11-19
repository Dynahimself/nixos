{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 13;
      font-thicken = true;
      window-padding-x = 10;
      window-padding-y = 10;
      window-decoration = false;
      background-opacity = 0.72;
      background-blur-radius = 20;
      mouse-hide-while-typing = true;
      clipboard-read = "allow";
      clipboard-write = "allow";
      shell-integration = "detect";
      confirm-close-surface = false;
      keybind = [
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"
        "ctrl+shift+t=new_tab"
        "ctrl+shift+w=close_surface"
        "ctrl+tab=next_tab"
        "ctrl+shift+tab=previous_tab"
        "ctrl+plus=increase_font_size:1"
        "ctrl+minus=decrease_font_size:1"
        "ctrl+0=reset_font_size"
      ];
    };
  };
}
