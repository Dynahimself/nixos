{ config, pkgs, lib, inputs, ... }:

{
  # Minimal home for WSL — dev tools only, no GUI

  home.username = "dyna";
  home.homeDirectory = "/home/dyna";
  home.stateVersion = "25.11";

  # Nixvim
  dyna.nixvim.enable = true;
  nixpkgs.config.allowUnfree = true;

  programs.git = {
    enable = true;
    userName = "Dynahimself";
    userEmail = "Dynasti.video@gmail.com";
    signing.format = null;
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" = {
        hostname = "ssh.github.com";
        port = 443;
        user = "git";
      };
    };
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initExtra = ''
      export PATH="$HOME/.local/bin:$PATH"

      # Jump to Windows home (WSL)
      win() {
        cd /mnt/c/Users/$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r') 2>/dev/null           || cd /mnt/c/Users/*/ 2>/dev/null           || echo "Not in WSL or Windows drive not mounted"
      }
    '';
    shellAliases = {
      ll = "ls -la";
    };
  };

  home.sessionPath = [ "$HOME/.local/bin" ];

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = builtins.fromTOML (
      builtins.readFile (
        pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/starship/starship/main/docs/public/presets/toml/catppuccin-powerline.toml";
          sha256 = "sha256-1bJv+8P9eP/0SBGAjfPTUFbetI9+1gWcql/RHtNQLsQ=";
        }
      )
    );
  };

  programs.bat.enable = true;
  programs.kitty.enable = true;
}
