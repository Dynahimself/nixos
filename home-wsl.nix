{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  # Minimal home for WSL — dev tools only, no GUI

  home.username = "dyna";
  home.homeDirectory = "/home/dyna";
  home.stateVersion = "25.11";

  # Nixvim
  dyna.nixvim.enable = true;

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
    settings = {
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
    initContent = ''
      fastfetch
      export PATH="$HOME/.local/bin:$PATH"

      # Jump to Windows home (WSL)
      win() {
        cd /mnt/c/Users/$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r') 2>/dev/null           || cd /mnt/c/Users/*/ 2>/dev/null           || echo "Not in WSL or Windows drive not mounted"
      }
    '';
    shellAliases = {
      ll = "ls -la";
      # WSL: ALWAYS this exact command — plain `nixos-rebuild switch` builds the wrong config
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#wsl";
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
          sha256 = "sha256-l4XVGxDFMzup1qjvRYVi/utUEmwVm/gpVYIJkCfBCpM=";
        }
      )
    );
  };

  programs.bat.enable = true;
  programs.kitty.enable = true;
}
