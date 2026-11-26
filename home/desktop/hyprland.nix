{ config, ... }:

let
  dot = p: config.lib.file.mkOutOfStoreSymlink "/etc/nixos/dotfiles/${p}";
in
{
  xdg.configFile."hypr" = { source = dot "hypr"; force = true; };
}
