{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      # Only show fastfetch on top-level interactive shells (not inside nvim :term or quick popups)
      if [[ -o interactive ]] && [[ -z "''${NVIM:-}" ]] && [[ "''${SHLVL:-1}" -le 2 ]] && [[ -t 1 ]]; then
        fastfetch
      fi
      export PATH="$HOME/.local/bin:$PATH"

      # Jump to Windows home (WSL)
      win() {
        cd /mnt/c/Users/$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r') 2>/dev/null \
          || cd /mnt/c/Users/*/ 2>/dev/null \
          || echo "Not in WSL or Windows drive not mounted"
      }

      # Jump to latest CEGEP C# homework folder
      tp() {
        local latest
        latest=$(ls -1dt "$HOME/cswip/Aoop/homeworks"/TP* 2>/dev/null | head -n1)
        if [[ -n "$latest" ]]; then
          cd "$latest" && pwd
        else
          cd "$HOME/cswip/Aoop" 2>/dev/null || echo "Homework dir not found"
        fi
      }
    '';
    shellAliases = {
      ls = "eza --icons --group-directories-first";
      ll = "eza -la --icons --git --group-directories-first";
      lt = "eza --tree --level=2 --icons";
      cat = "bat --style=plain";
      v = "nvim";
      lg = "lazygit";
      ld = "lazydocker";
      npush = "nas-cache-push";
      nr = "nh os switch /etc/nixos";
      nrd = "nh os switch --dry /etc/nixos";
      nru = "nh os switch --update /etc/nixos";
      hreload = "hyprctl reload";
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

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      side-by-side = true;
      line-numbers = true;
      syntax-theme = "Catppuccin Mocha";
      hyperlinks = true;
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height=55%"
      "--layout=reverse"
      "--border=rounded"
      "--info=inline"
      "--bind=ctrl-e:down,ctrl-i:up"
    ];
    historyWidget.command = ""; # Keep Atuin on Ctrl-R
    fileWidget = {
      command = "fd --type f --hidden --follow --exclude .git";
      options = [ "--preview='bat --color=always --style=numbers --line-range=:200 {}'" ];
    };
    changeDirWidget = {
      command = "fd --type d --hidden --follow --exclude .git";
      options = [ "--preview='eza --tree --level=2 --icons --color=always {}'" ];
    };
  };

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
