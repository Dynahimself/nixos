# hosts/laptop/configuration.nix
{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ ./hardware-configuration.nix ]; # You need to generate this on the laptop

  # Laptop specific hostname
  networking.hostName = "laptop";

  # NVIDIA Optimus Setup
  hardware.nvidia = {
    modesetting.enable = true;
    # Enable the Nvidia settings menu
    nvidiaSettings = true;

    # Driver version
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    prime = {
      offload.enable = true;
    };
  };

  # Power management
  services.tlp.enable = true;
}
