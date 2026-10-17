# Shared base for headless servers (nas, pi) — NOT base.nix (that one has GUI/desktop stuff)
{ config, pkgs, ... }:

{
  time.timeZone = "America/Toronto";
  i18n.defaultLocale = "en_US.UTF-8";

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  users.users.dyna = {
    isNormalUser = true;
    description = "Dyna";
    shell = pkgs.zsh;
    extraGroups = [ "wheel" "docker" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDU+0EUic8J/6x3rGQdbxoLPMSyL69NAylM7WAc7qJ6e dyna@raspberrypi"
    ];
  };
  programs.zsh.enable = true;

  services.openssh.enable = true;
  services.openssh.settings.passwordAuthentication = false;

  environment.systemPackages = with pkgs; [
    git vim htop curl wget tmux
  ];

  # NOTE: keep lower than desktop's to avoid stateVersion churn on first switch
  # nas installed at 25.05; new hosts set their own in their profile.
}
