{ config, ... }:

let
  dot = p: config.lib.file.mkOutOfStoreSymlink "/etc/nixos/dotfiles/${p}";
in
{
  xdg.configFile."wlogout" = { source = dot "wlogout"; force = true; };
}
