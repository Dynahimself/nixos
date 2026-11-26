{ config, lib, pkgs, ... }:

{
  gtk = {
    enable = true;
    theme = {
      name = "Catppuccin-Mocha-Mauve";
      package = pkgs.magnetic-catppuccin-gtk;
    };
    gtk4.theme = config.gtk.theme;
    font = {
      name = "JetBrains Mono";
      size = 11;
    };
  };

  xdg.configFile."gtk-3.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/settings.ini".force = true;

  home.activation = {
    copyGtkConfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      rm -rf $HOME/.gtkrc-2.0
    '';
  };
}
