{ pkgs, ... }:

{
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
        cd /mnt/c/Users/$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r') 2>/dev/null \
          || cd /mnt/c/Users/*/ 2>/dev/null \
          || echo "Not in WSL or Windows drive not mounted"
      }
    '';
    shellAliases = {
      ll = "ls -la";
    };
  };

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

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      style = "compact";
      inline_height = 18;
      search_mode = "fuzzy";
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
  };

  xdg.configFile."fastfetch/config.jsonc".source = ../dotfiles/configs/fastfetch.jsonc;
}
