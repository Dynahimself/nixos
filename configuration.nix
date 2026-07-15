# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:

{
  imports = [
    ./packages.nix
  ];

  # Catppuccin
  catppuccin.enable = true;
  catppuccin.cursors.enable = true;

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Crucial for running 32-bit games (like Wine/Proton)
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  services.tailscale.enable = true;
  documentation.doc.enable = false;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "iwd";

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

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
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.zsh = {
    enable = true;
  };

  # User account
  users.users.dyna = {
    isNormalUser = true;
    description = "Dyna";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  programs.firefox.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports for Source Dedicated Server
    extraCompatPackages = [
      pkgs.proton-ge-bin
    ];

    # Enable Gamescope (the micro-compositor used on the Steam Deck)
    gamescopeSession.enable = true;
  };

  # Optimize system performance for gaming on demand
  programs.gamemode.enable = true;

  nixpkgs.config.allowUnfree = true;

  #OpenlDAP quick fix
  nixpkgs.overlays = [
    (final: prev: {
      openldap = prev.openldap.overrideAttrs (oldAttrs: {
        doCheck = false;
      });
    })
  ];

  nix.settings = {
    max-jobs = 6;
    cores = 0;
  };

  system.stateVersion = "25.11";
}
