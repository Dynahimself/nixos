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
  environment.etc."hypr/monitor.conf".text = "monitor = , preferred, auto, 1  ";
}
