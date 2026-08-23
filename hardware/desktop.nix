{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./desktop-hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;

  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;
  # Desktop specific hostname
  networking.hostName = "desktop";

  environment.etc."hypr/monitor.conf".text = ''
    monitor = DP-3, 2560x1440@240, 0x0, 1
    monitor = HDMI-A-1, 1920x1080@144, 2560x0, 1
  '';

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
}
