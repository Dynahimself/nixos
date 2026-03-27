{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

let
  # Pin the Zen-specific Catppuccin theme
  catppuccin-zen = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "zen-browser";
    rev = "main"; # Pin to a commit hash for reproducibility
    sha256 = "5A57Lyctq497SSph7B+ucuEyF1gGVTsuI3zuBItGfg4=";
  };

  # Configure these to match your preference
  flavor = "Mocha"; # Mocha, Latte, Frappe, Macchiato
  accent = "Mauve"; # Mauve, Blue, Green, etc.

  themePath = "${catppuccin-zen}/themes/${flavor}/${accent}";
in
{
  home.username = "dyna";
  home.homeDirectory = "/home/dyna";
  home.stateVersion = "25.11";

  # ──────────────────────────────────────────────
  # ZEN BROWSER CATPPUCCIN THEMING
  # ──────────────────────────────────────────────
  # TODO: Replace xxxxxxxx.default-default with your actual profile name from ~/.zen/
  home.file.".zen/d43yraaj.default-default/chrome/userChrome.css".source =
    "${themePath}/userChrome.css";

  home.file.".zen/d43yraaj.default-default/chrome/userContent.css".source =
    "${themePath}/userContent.css";

  home.file.".zen/d43yraaj.default-default/chrome/zen-logo-mocha.svg".source =
    "${themePath}/zen-logo-mocha.svg";

  # Enable userChrome support and compact mode optional tweaks
  home.file.".zen/d43yraaj.default-default/user.js".text = ''
    user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
    user_pref("browser.tabs.drawInTitlebar", true);
    user_pref("browser.compactmode.show", true);
    user_pref("zen.view.compact", false);  # Set true if you want compact mode by default
  '';

  # ... rest of your config (Neovim, Git, ZSH, etc.) remains identical ...

  programs.neovim = {
    enable = true;
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
    theme = {
      name = "Catppuccin-Mocha-Standard-Mauve-Dark";
      package = pkgs.magnetic-catppuccin-gtk {
        variant = "mocha";
        accents = [ "mauve" ];
        size = "standard"; # or "compact"
        tweaks = [ ]; # add "black" for #000000 backgrounds, "rimless" for no borders
      };
    };
    font = {
      name = "JetBrains Mono";
      size = 11;
    };
  };

  # War casualties
  home.file.".gtkrc-2.0".force = true;
  xdg.configFile."gtk-3.0/settings.ini".force = true;
  xdg.configFile."gtk-4.0/settings.ini".force = true;

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
  xdg.configFile."nvim".source = ./dotfiles/nvim;
  xdg.configFile."hypr".source = ./dotfiles/hypr;

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
      background-opacity = 0.65;
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
