{ config, pkgs, ... }:

{
  # Core system settings shared by all hosts (GUI-free)

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

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # User account
  users.users.dyna = {
    isNormalUser = true;
    description = "Dyna";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  programs.zsh.enable = true;

  #OpenLDAP quick fix
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
    options = "--delete-older-than 7d";
  };
  nix.optimise.automatic = true;

  # LanguageTool local server
  services.languagetool = {
    enable = true;
    port = 8081;
    allowOrigin = "*";
  };

  system.stateVersion = "25.11";
}
