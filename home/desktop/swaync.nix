{ config, ... }:

let
  dot = p: config.lib.file.mkOutOfStoreSymlink "/etc/nixos/dotfiles/${p}";
in
{
  xdg.configFile."swaync" = { source = dot "swaync"; force = true; };
}
