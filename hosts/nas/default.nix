# TerraMaster F2-425 — headless media/storage server profile
{ config, pkgs, lib, ... }:

{
  imports = [
    ../../system/server
    ./hardware-configuration.nix
    ../../modules/srvlaunch.nix
    ./services
  ];

  system.stateVersion = "25.05";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nas";
  networking.useDHCP = true;
  # public resolvers: qbittorrent's DNS gets marked into the tunnel (LAN resolver unreachable there)
  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];

  boot.kernelModules = [ "coretemp" ];

  services.tailscale.enable = true;
  services.smartd.enable = true;
  virtualisation.docker.enable = true;

  networking.firewall.enable = false; # LAN + tailscale only; panel on 8300
}
