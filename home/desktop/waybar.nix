{ config, ... }:

let
  dot = p: config.lib.file.mkOutOfStoreSymlink "/etc/nixos/dotfiles/${p}";
in
{
  xdg.configFile."waybar" = { source = dot "waybar"; force = true; };
}
