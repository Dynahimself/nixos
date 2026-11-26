{ config, ... }:

let
  dot = p: config.lib.file.mkOutOfStoreSymlink "/etc/nixos/dotfiles/${p}";
in
{
  xdg.configFile."swayosd" = { source = dot "swayosd"; force = true; };
}
