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
    monitorv2 {
      output = DP-3
      mode = 2560x1440@240
      position = 0x0
      scale = 1
      sdrbrightness = 1.2
      sdrsaturation = 1.0
      supports_hdr = 1
    }

    monitorv2 {
      output = HDMI-A-1
      mode = 1920x1080@144
      position = 2560x0
      scale = 1
    }
  '';

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
}
