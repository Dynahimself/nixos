{ config, pkgs, ... }:

{
  imports = [
    ./base.nix
    ./gui.nix
    ./packages.nix
  ];
}
