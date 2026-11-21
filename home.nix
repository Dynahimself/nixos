{ config, ... }:

let
  dot = p: config.lib.file.mkOutOfStoreSymlink "/etc/nixos/dotfiles/${p}";
in
{
  imports = [
    ./home/ghostty.nix
    ./home/zen.nix
    ./home/shell.nix
    ./home/theming.nix
    ./home/colemak-apps.nix
    ./home/scripts.nix
  ];

  # Nixvim editor (Colemak-DH workbench)
  dyna.nixvim.enable = true;
  programs.neovim.enable = false;

  home.username = "dyna";
  home.homeDirectory = "/home/dyna";
  home.stateVersion = "25.11";
  home.sessionPath = [ "$HOME/.local/bin" ];

  programs.git = {
    enable = true;
    settings.user = {
      name = "Dynahimself";
      email = "Dynasti.video@gmail.com";
    };
    signing.format = null;
  };

  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    matchBlocks = {
      "raspberrypi pi" = {
        hostname = "100.68.54.112";
        user = "dyna";
      };
      "nas" = {
        hostname = "100.97.162.110";
        user = "dyna";
      };
      "laptop" = {
        hostname = "100.116.179.60";
        user = "dyna";
      };
      "laptop-win dyna-4" = {
        hostname = "100.110.58.123";
        user = "olivi";
      };
      "desktop desktop-1" = {
        hostname = "100.89.63.116";
        user = "dyna";
      };
      "github.com" = {
        hostname = "ssh.github.com";
        port = 443;
        user = "git";
      };
      "*" = {
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
      };
    };
  };

  xdg.configFile."hypr" = { source = dot "hypr"; force = true; };
  xdg.configFile."waybar" = { source = dot "waybar"; force = true; };
  xdg.configFile."rofi" = { source = dot "rofi"; force = true; };
  xdg.configFile."swaync" = { source = dot "swaync"; force = true; };
  xdg.configFile."wlogout" = { source = dot "wlogout"; force = true; };
  xdg.configFile."swayosd" = { source = dot "swayosd"; force = true; };
  home.file."backgrounds" = { source = dot "backgrounds"; force = true; };
}
