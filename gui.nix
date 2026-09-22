{ config, pkgs, ... }:

{
  # GUI / Desktop / Gaming — shared by desktop + laptop, NOT WSL

  # Catppuccin
  catppuccin.enable = true;
  catppuccin.cursors.enable = true;

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.tailscale.enable = true;
  services.openssh.enable = true;
  documentation.doc.enable = false;
  networking.interfaces.eno1.wakeOnLan.enable = true;

  virtualisation.waydroid.enable = true;
  virtualisation.waydroid.package = pkgs.waydroid-nftables;

  environment.systemPackages = [ pkgs.wl-clipboard ];

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "wpa_supplicant";

  # Enable X11
  services.xserver.enable = true;

  # Display Manager - SDDM with session selection at login
  services.displayManager.sddm.enable = true;

  # KDE Plasma as fallback session
  services.desktopManager.plasma6.enable = true;

  # bspwm - primary tiling WM
  services.xserver.windowManager.bspwm.enable = true;

  #Hyprland
  programs.hyprland.enable = true;

  # xdg-portal for screen sharing, file pickers, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    glibc
    libaio
    stdenv.cc.cc
    zlib
    openssl
    libxml2
    curl
  ];

  services.envfs.enable = true;

  services.printing.enable = true;
  hardware.keyboard.zsa.enable = true;
  hardware.openrazer.enable = true;
  hardware.openrazer.users = [ "dyna" ];

  # Sound with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
  services.blueman.enable = true;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.firefox.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    extraCompatPackages = [ pkgs.proton-ge-bin ];
    gamescopeSession.enable = true;
  };

  programs.gamemode.enable = true;

  nix.settings.max-jobs = 6;
  nix.settings.cores = 0;

  swapDevices = [
    { device = "/var/lib/swapfile"; size = 32 * 1024; }
  ];
}
