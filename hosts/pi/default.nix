# Raspberry Pi 5 — headless server profile (STUB, apply when the NVMe arrives)
{ config, pkgs, lib, ... }:

{
  imports = [
    ../../system/server
    ../../modules/srvlaunch.nix
    ./srvlaunch.nix
  ];

  nixpkgs.hostPlatform = "aarch64-linux";
  system.stateVersion = "25.05";

  networking.hostName = "pi";
  networking.useDHCP = true;

  # refined on install day (raspi firmware + bootloader)
  boot.loader.systemd-boot.enable = true;
  fileSystems."/" = lib.mkDefault {
    device = "/dev/disk/by-label/NIXOS_SD";
    fsType = "ext4";
  };

  services.tailscale.enable = true;

  environment.systemPackages = with pkgs; [
    git vim htop curl wget
  ];

}
