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
  initExtra = ''
  fastfetch
  '';
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

  settings = {
    # These get merged with catppuccin's palette injection
    format = "$directory$git_branch$git_status$rust$nodejs$python$nix_shell$cmd_duration$line_break$character";

    character = {
      success_symbol = "[❯](bold green)";
      error_symbol = "[❯](bold red)";
    };

    directory = {
      style = "bold lavender";
      truncation_length = 3;
      truncate_to_repo = true;
    };

    git_branch = {
      format = "[$symbol$branch]($style) ";
      style = "bold mauve";
    };

    git_status = {
      format = "[$all_status$ahead_behind]($style) ";
      style = "bold red";
    };

    nix_shell = {
      format = "[$symbol$state]($style) ";
      style = "bold blue";
    };

    cmd_duration = {
      format = "[$duration]($style) ";
      style = "bold yellow";
    };

    # Add more modules as needed—rust, nodejs, python, etc.
    # Each styled with catppuccin color names: rose, flamingo, pink, mauve, red, maroon, peach, yellow, teal, green, sapphire, blue, sky, lavender, text, subtext1, subtext0, overlay2, overlay1, overlay0, surface2, surface1, surface0, base, mantle, crust
  };
};

catppuccin.starship.enable = true;  # keeps feeding the palette

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
