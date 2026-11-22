{ pkgs, ... }:

{
  programs.ghostty = {
    enable = true;
    package = pkgs.ghostty;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 13;
      font-thicken = true;
      cursor-style = "bar";
      cursor-style-blink = false;
      window-padding-x = 10;
      window-padding-y = 10;
      window-padding-balance = true;
      window-decoration = false;
      background-opacity = 0.78;
      background-blur-radius = 20;
      mouse-hide-while-typing = true;
      copy-on-select = "clipboard";
      clipboard-read = "allow";
      clipboard-write = "allow";
      shell-integration = "detect";
      confirm-close-surface = false;
      gtk-single-instance = true;
      scrollback-limit = 100000;
      unfocused-split-opacity = 0.88;
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
        # Colemak-DH split management (n/e/i/o)
        "alt+shift+v=new_split:right"
        "alt+shift+s=new_split:down"
        "ctrl+shift+z=toggle_split_zoom"
        "ctrl+shift+n=goto_split:left"
        "ctrl+shift+e=goto_split:bottom"
        "ctrl+shift+i=goto_split:top"
        "ctrl+shift+o=goto_split:right"
      ];
    };
  };
}
