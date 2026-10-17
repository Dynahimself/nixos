# Raspberry Pi 5 — headless server profile (STUB, apply when the NVMe arrives)
{ config, pkgs, lib, ... }:

{
  imports = [
    ../server-base.nix
    ../modules/srvlaunch.nix
  ];

  nixpkgs.hostPlatform = "aarch64-linux";
  system.stateVersion = "25.05";

  networking.hostName = "pi";
  networking.useDHCP = true;

  # refined on install day (raspi firmware + bootloader)
  boot.loader.systemd-boot.enable = true;

  services.tailscale.enable = true;

  environment.systemPackages = with pkgs; [
    git vim htop curl wget
  ];

  # srvlaunch panel (same launcher as the NAS)
  services.srvlaunch = {
    enable = true;
    http_port = 8300;
    apps = {
      hermes = {
        displayName = "Hermes";
        url = "http://100.68.54.112:8200";
        units = [ ]; # hermes.service created on pi-NixOS day
        color = "#f5c2e7";
      };
      chub-gems = {
        displayName = "Chub Gems";
        url = "http://100.68.54.112:5123";
        units = [ ];
        color = "#cba6f7";
      };
    };
  };
}
