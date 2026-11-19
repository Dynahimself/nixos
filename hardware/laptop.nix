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
    extraEntries = ''
      menuentry "Windows" {
        insmod part_gpt
        insmod fat
        insmod search_fs_uuid
        insmod chain
        search --no-floppy --fs-uuid --set=root 68BD-86BC
        chainloader /EFI/Microsoft/Boot/bootmgfw.efi
      }
    '';
    configurationLimit = 3; # ESP is 256MB and shared with Windows
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.initrd.compressor = "zstd";
  boot.initrd.compressorArgs = [ "-19" "-T0" ];
  boot.kernelPackages = pkgs.linuxPackages; # temp LTS (6.18): zen 7.3.4 has a bh_worker NULL deref panic at boot
  boot.blacklistedKernelModules = [ "xe" ];

  networking.hostName = "laptop";

  # Lid switch behavior
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  powerManagement.enable = true;
  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];

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

  environment.etc."hypr/monitor.conf".text = ''
    monitor = eDP-1, 1920x1080@144, 0x0, 1
  '';

  #  environment.etc."hypr/monitor.conf".text = ''
  #    input {
  #      kb_layout = us
  #      kb_variant = colemak_dh
  #    }
  #  '';

  #  services.xserver.xkb = {
  #    layout = "us";
  #    variant = "colemak_dh";
  #  };

  console.useXkbConfig = true;
  services.tlp = {
    enable = true;
    settings = {
      STOP_CHARGE_THRESH_BAT0 = 70;
    };
  };
}
