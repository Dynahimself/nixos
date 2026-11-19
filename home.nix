{ ... }:

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
    settings = {
      "*" = {
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
      };
      "github.com" = {
        hostname = "ssh.github.com";
        port = 443;
        user = "git";
      };
    };
  };

  xdg.configFile."hypr".source = ./dotfiles/hypr;
  xdg.configFile."waybar".source = ./dotfiles/waybar;
  xdg.configFile."rofi".source = ./dotfiles/rofi;
  xdg.configFile."swaync".source = ./dotfiles/swaync;
  xdg.configFile."wlogout".source = ./dotfiles/wlogout;
  xdg.configFile."swayosd".source = ./dotfiles/swayosd;
  home.file."backgrounds".source = ./dotfiles/backgrounds;
}
