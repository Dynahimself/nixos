{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  cshubPkg = import ./tools/cshub { inherit pkgs; };
  fleetPkg = pkgs.writeShellScriptBin "fleet" (
    builtins.replaceStrings [ "#!/usr/bin/env bash\n" ] [ "" ] (
      builtins.readFile ./dotfiles/scripts/fleet
    )
  );
  fleetClipPkg = pkgs.writeShellScriptBin "fleet-clip" (
    builtins.replaceStrings [ "#!/usr/bin/env bash\n" ] [ "" ] (
      builtins.readFile ./dotfiles/scripts/fleet-clip
    )
  );
  motionCoachPkg = pkgs.writeShellScriptBin "motion-coach" (
    builtins.replaceStrings [ "#!/usr/bin/env bash\n" ] [ "" ] (
      builtins.readFile ./dotfiles/scripts/motion-coach
    )
  );
in
{

  home.username = "dyna";
  home.homeDirectory = "/home/dyna";
  home.stateVersion = "25.11";
  home.sessionPath = [ "$HOME/.local/bin" ];

  # Disable Hyprland LSP stubs on WSL
  dyna.nixvim = {
    enable = true;
    hyprStubs = false;
  };
  programs.neovim.enable = false;

  catppuccin = {
    enable = true;
    autoEnable = true;
    flavor = "mocha";
    starship.enable = true;
  };

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

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      if [[ -o interactive ]] && [[ -z "''${NVIM:-}" ]] && [[ "''${SHLVL:-1}" -le 2 ]] && [[ -t 1 ]]; then
        fastfetch
      fi
      export PATH="$HOME/.local/bin:$PATH"

      # cd to Windows user directory
      win() {
        cd /mnt/c/Users/$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r') 2>/dev/null \
          || cd /mnt/c/Users/Olivi 2>/dev/null \
          || echo "Windows drive not mounted"
      }

      # cd to latest TP directory
      tp() {
        local latest
        latest=$(ls -1dt "$HOME/cswipp"/TP* "$HOME/cswip/Aoop/homeworks"/TP* /mnt/c/Users/Olivi/cswip/TP* 2>/dev/null | head -n1)
        if [[ -n "$latest" ]]; then
          cd "$latest" && pwd
        else
          cd "$HOME/cswipp" 2>/dev/null || cd /mnt/c/Users/Olivi/cswip 2>/dev/null || echo "Homework dir not found"
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
      csh = "cshub";
      csa = "cshub agenda";
      csc = "cshub cal";
      csd = "cshub dash";
      # Pin #wsl flake target
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#wsl";
      nr = "nh os switch /etc/nixos -H wsl";
    };
  };

  home.packages = [
    cshubPkg
    fleetPkg
    fleetClipPkg
    motionCoachPkg
  ];

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
    historyWidget.command = "";
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
    keymap.mgr.prepend_keymap = [
      { on = "n"; run = "leave"; desc = "Go back to parent directory"; }
      { on = "e"; run = "arrow 1"; desc = "Move cursor down"; }
      { on = "i"; run = "arrow -1"; desc = "Move cursor up"; }
      { on = "o"; run = "enter"; desc = "Enter child directory"; }
      { on = "k"; run = "find_arrow"; desc = "Next found"; }
      { on = "K"; run = "find_arrow --previous"; desc = "Previous found"; }
    ];
  };

  xdg.configFile."lazygit/config.yml".source = ./dotfiles/configs/lazygit.yml;
  xdg.configFile."zellij/config.kdl".source = ./dotfiles/configs/zellij.kdl;
  xdg.configFile."fastfetch/config.jsonc".source = ./dotfiles/configs/fastfetch.jsonc;
}
