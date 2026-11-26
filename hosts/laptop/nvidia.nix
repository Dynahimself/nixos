{ config, lib, ... }:

{
  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];
  services.displayManager.sddm.wayland.enable = lib.mkForce true;

  # NVIDIA Optimus Setup
  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # This is the critical bit for suspend/resume on Nvidia laptops
    powerManagement.enable = true;

    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    # finegrained = true;  # uncomment if you want runtime power management (turns off GPU when unused)
  };
}
