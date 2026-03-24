{ config, pkgs, nvim-config, ... }:
{
  home.username = "dyna";
  home.homeDirectory = "/home/dyna";
  home.stateVersion = "24.11";

  # ──────────────────────────────────────────────
  # GIT
  # ──────────────────────────────────────────────
  programs.git = {
    enable = true;
    userName = "Dynahimself";
    userEmail = "Dynasti.video@gmail.com";
    signing.format = null;

  };

  # ──────────────────────────────────────────────
  # BASH
  # ──────────────────────────────────────────────
  programs.zsh = {
    enable = true;
  enableCompletion = true;
  autosuggestion.enable = true;
  syntaxHighlighting.enable = true;
    shellAliases = {
      ll = "ls -la";
      update = "sudo nixos-rebuild switch --flake .#nixos";
    };
  };

  # ──────────────────────────────────────────────
  # THEMING (Catppuccin)
  # ──────────────────────────────────────────────
  catppuccin.enable = true;
  catppuccin.flavor = "mocha";

  programs.bat = {
    enable = true;
  };

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };
  catppuccin.starship.enable = true;

  # ──────────────────────────────────────────────
  # NEOVIM + LAZYVIM
  # ──────────────────────────────────────────────
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;
  };

  # LazyVim dependencies
  home.packages = with pkgs; [

  # ==========================================
  # 6. DATABASES (vim-dadbod)
  # ==========================================
  postgresql_15        # vim-dadbod (psql binary)
  sqlite              # vim-dadbod (sqlite3 binary)
  # mysql80            # vim-dadbod (uncomment if you use MySQL)
];

  # YOUR LAZYVIM CONFIG FROM GITHUB
    # Symlink your config to ~/.config/nvim
  xdg.configFile."nvim" = {
    source = nvim-config;
    recursive = true;
  };



  # ──────────────────────────────────────────────
  # KITTY (you have it in system, but theme it here)
  # ──────────────────────────────────────────────
  programs.kitty = {
    enable = true;
    settings = {
      font_size = "12";
      enable_audio_bell = false;
    };
  };
}
