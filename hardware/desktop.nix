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

  # Desktop specific hostname
  networking.hostName = "desktop";
  hardware.nvidia = {
    modesetting.enable = true;
    # Enable the Nvidia settings menu
    nvidiaSettings = true;
    open = false;

    # Driver version
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  environment.etc."hypr/monitor.conf".text = ''
    monitor = DP-1, 1920x1080@144, 0x0, 1
    monitor = HDMI-A-1, 1920x1080@75, 1920x0, 1
  '';
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
}
