{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  # 2. EVERYTHING ELSE lives inside this main attribute set
  home.username = "dyna";
  home.homeDirectory = "/home/dyna";
  home.stateVersion = "25.11";

  # Configure Neovim
  programs.neovim = {
    enable = true;
    # Directly use the package from the flake input
    # This bypasses the "attribute missing" error entirely
    package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;
  };

  # ──────────────────────────────────────────────
  # GIT
  # ──────────────────────────────────────────────
  programs.git = {
    enable = true;
    userName = "Dynahimself";
    userEmail = "Dynasti.video@gmail.com";
    signing.format = null;
  };

  home.pointerCursor = {
    gtk.enable = true;
    package = pkgs.catppuccin-cursors.mochaDark;
    name = "Catppuccin-Mocha-Dark-Cursors";
    size = 24;
  };

  gtk = {
    enable = true;
    cursorTheme = {
      name = "Catppuccin-Mocha-Dark-Cursors";
      package = pkgs.catppuccin-cursors.mochaDark;
    };
  };

  # ──────────────────────────────────────────────
  # ZSH
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

  programs.bat.enable = true;

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = builtins.fromTOML (
      builtins.readFile (
        pkgs.fetchurl {
          url = "https://raw.githubusercontent.com/starship/starship/refs/heads/master/docs/public/presets/toml/catppuccin-powerline.toml";
          sha256 = "0bd8zx0bpri63rnb9dva0rav75d3i2wrzw44h63m75hq5220r26g";
        }
      )
    );
  };
  catppuccin.starship.enable = true;

  # ──────────────────────────────────────────────
  # NEOVIM CONFIG SYMLINK
  # ──────────────────────────────────────────────
  # This symlinks your local /etc/nixos/nvim folder into ~/.config/nvim
  xdg.configFile."nvim".source = ./nvim;

  # ──────────────────────────────────────────────
  # KITTY
  # ──────────────────────────────────────────────
  programs.kitty = {
    enable = true;
    settings = {
      font_size = "12";
      enable_audio_bell = false;
    };
  };

  # ──────────────────────────────────────────────
  # GHOSTTY
  # ──────────────────────────────────────────────
  programs.ghostty = {
    enable = true;
    package = if pkgs.stdenv.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 13;
      font-thicken = true;
      window-padding-x = 8;
      window-padding-y = 8;
      background-opacity = 0.95;
      mouse-hide-while-typing = true;
      clipboard-read = "allow";
      clipboard-write = "allow";
      shell-integration = "detect";
      keybind = [
        "ctrl+shift+c=copy_to_clipboard"
        "ctrl+shift+v=paste_from_clipboard"
        "ctrl+shift+t=new_tab"
        "ctrl+shift+w=close_surface"
        "ctrl+tab=next_tab"
        "ctrl+shift+tab=previous_tab"
        "ctrl+plus=increase_font_size:1"
        "ctrl+minus=decrease_font_size:1"
        "ctrl+0=reset_font_size"
      ];
    };
  };
}
