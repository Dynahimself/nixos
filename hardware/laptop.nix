# hosts/laptop/configuration.nix
{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ./laptop-hardware-configuration.nix
  ];

  # Laptop specific hostname
  networking.hostName = "laptop";

  # NVIDIA Optimus Setup
  hardware.nvidia = {
    modesetting.enable = true;
    # Enable the Nvidia settings menu
    nvidiaSettings = true;
    open = false;

    # Driver version
    package = config.boot.kernelPackages.nvidiaPackages.stable;

  };

  # Power management
  services.tlp.enable = true;
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "colemak_dh";
  };
  console.useXkbConfig = true;
}
