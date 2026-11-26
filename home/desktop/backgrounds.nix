{ config, ... }:

let
  dot = p: config.lib.file.mkOutOfStoreSymlink "/etc/nixos/dotfiles/${p}";
in
{
  home.file."backgrounds" = { source = dot "backgrounds"; force = true; };
}
