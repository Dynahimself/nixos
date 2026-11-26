{ pkgs, ... }:

{
  imports = [
    ./cli.nix
    ./shell.nix
    ./networking.nix
    ./dev-tools.nix
    ./toolchains.nix
    ./hyprland.nix
    ./desktop-apps.nix
    ./gaming.nix
    ./peripherals.nix
    ./fonts.nix
  ];

  nixpkgs.config.permittedInsecurePackages = [ "ventoy-full-qt" ];

  environment.shells = with pkgs; [
    zsh
    bash
  ];

  users.users.dyna = {
    packages = with pkgs; [
      kdePackages.kate
    ];
  };
}
