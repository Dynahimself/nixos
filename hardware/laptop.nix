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

  # Bootloader.
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub = {
    enable = true;
    efiSupport = true;
    device = "nodev";
    useOSProber = true;
    extraEntries = ''
      menuentry "Windows" --class windows {
        insmod part_gpt
        insmod fat
        insmod chain
        set root='hd0,gpt1'
        chainloader /EFI/Microsoft/Boot/bootmgfw.efi
      }
    '';
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_zen;

  networking.hostName = "laptop";

  # Lid switch behavior
  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "ignore";
  };

  powerManagement.enable = true;

  # NVIDIA Optimus Setup
  hardware.nvidia = {
    modesetting.enable = true;
    nvidiaSettings = true;
    open = false;
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # This is the critical bit for suspend/resume on Nvidia laptops
    powerManagement.enable = true;
    # finegrained = true;  # uncomment if you want runtime power management (turns off GPU when unused)
  };

  environment.etc."hypr/monitor.conf".text = ''
    input {
      kb_layout = us
      kb_variant = colemak_dh
    }
  '';

  services.xserver.xkb = {
    layout = "us";
    variant = "colemak_dh";
  };

  console.useXkbConfig = true;
}
