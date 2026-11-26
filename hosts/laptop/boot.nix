{ pkgs, ... }:

{
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
    configurationLimit = 10; # kernels now live on 510GB ext4 /, ESP is at /boot/efi
  };

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.initrd.compressor = "zstd";
  boot.initrd.compressorArgs = [ "-19" "-T0" ];
  boot.kernelPackages = pkgs.linuxPackages; # temp LTS (6.18): zen 7.3.4 has a bh_worker NULL deref panic at boot
  boot.blacklistedKernelModules = [ "xe" ];
}
