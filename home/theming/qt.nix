{ ... }:

{
  qt = {
    enable = true;
    platformTheme.name = "qtct";
    style.name = "kvantum";
  };

  xdg.configFile."kdeglobals" = {
    source = ../../dotfiles/configs/kdeglobals;
    force = true;
  };
}
