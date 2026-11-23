{ config, pkgs, ... }:

{

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

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "dyna" ];
    extra-substituters = [ "http://100.97.162.110:5000?priority=30" ];
    extra-trusted-public-keys = [ "nas-cache-1:cJXZP/MSyt9AvkbMiXX0SrbkZqt9zU1qlq0OIkwyCcU=" ];
    connect-timeout = 3;
    fallback = true;
  };
  nixpkgs.config.allowUnfree = true;

  users.users.dyna = {
    isNormalUser = true;
    description = "Dyna";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  programs.zsh.enable = true;

  # Skip openldap tests
  nixpkgs.overlays = [
    (final: prev: {
      openldap = prev.openldap.overrideAttrs (oldAttrs: {
        doCheck = false;
      });
    })
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;

  services.languagetool = {
    enable = true;
    port = 8081;
    allowOrigin = "*";
  };

  system.stateVersion = "25.11";
}
