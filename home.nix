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
    rev = "main";
    sha256 = "5A57Lyctq497SSph7B+ucuEyF1gGVTsuI3zuBItGfg4=";
  };

  flavor = "Mocha";
  accent = "Mauve";
  themePath = "${catppuccin-zen}/themes/${flavor}/${accent}";

  spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  profileName = "dynas";
in
{
  home.username = "dyna";
  home.homeDirectory = "/home/dyna";
  home.stateVersion = "25.11";

  # 1. THE SOURCE OF TRUTH: profiles.ini
  home.file.".zen/profiles.ini".text = ''
    [General]
    StartWithLastProfile=1
    Version=2

    [Profile0]
    Name=default
    IsRelative=1
    Path=${profileName}
    Default=1
  '';

  # 2. THE THEME FILES
  home.file.".zen/${profileName}/chrome/userChrome.css".source = "${themePath}/userChrome.css";

  home.file.".zen/${profileName}/chrome/userContent.css".source = "${themePath}/userContent.css";

  home.file.".zen/${profileName}/chrome/zen-logo-mocha.svg".source =
    "${themePath}/zen-logo-mocha.svg";

  # 3. SETTINGS & TWEAKS
  home.file.".zen/${profileName}/user.js".text = ''
    user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
    user_pref("browser.tabs.drawInTitlebar", true);
    user_pref("browser.compactmode.show", true);
    user_pref("zen.view.compact", false);
  '';

  #Zen mods
  home.file.".zen/${profileName}/zen-themes.json".source = ./dotfiles/zen-themes.json;

 programs.neovim.enable = false;

home.packages = [
  inputs.neovim-nightly-overlay.packages.${pkgs.system}.default
};
];
  # ──────────────────────────────────────────────
  # GIT
  # ──────────────────────────────────────────────
  programs.git = {
    enable = true;
    userName = "Dynahimself";
    userEmail = "Dynasti.video@gmail.com";
    signing.format = null;
  };

  programs.ssh = {
    enable = true;
    matchBlocks = {
      "github.com" =         hostname = "ssh.github.com";
        port = 443;
        user = "git";
      };
    };
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
      name = "Catppuccin-Mocha-Mauve"; # or "Catppuccin-Mocha-Mauve-Dark" if menus look off
      package = pkgs.magnetic-catppuccin-gtk;
    };
    font = {
      name = "JetBrains Mono";
      size = 11;
    };
  };

  # War casualties
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
  xdg.configFile."hypr".source = ./dotfiles/hypr;
  xdg.configFile."waybar".source = ./dotfiles/waybar;
  xdg.configFile."rofi".source = ./dotfiles/rofi;
  home.file."backgrounds".source = ./dotfiles/backgrounds;

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
  # Spicetify
  # ──────────────────────────────────────────────
  programs.spicetify = {
    enable = true;
    enabledExtensions = with spicePkgs.extensions; [
      adblockify
      hidePodcasts
      shuffle
    ];
    theme = spicePkgs.themes.catppuccin;
    colorScheme = "mocha";
  };

  # ──────────────────────────────────────────────
  # Flameshot
  # ──────────────────────────────────────────────
  services.flameshot = {
    enable = true;
    # Enable wayland support with this build flag
    package = pkgs.flameshot.override {
      enableWlrSupport = true;
    };

    settings = {
      General = {
        disabledTrayIcon = true;
        showStartupLaunchMessage = false;

        # Auto save to this path
        savePath = "$HOME/Pictures/Screenshots";
        savePathFixed = true;
        saveAsFileExtension = ".jpg";
        filenamePattern = "%F_%H-%M";
        drawThickness = 1;
        copyPathAfterSave = true;

        # For wayland
        useGrimAdapter = true;
      };
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
  home.activation = {
    copyGtkConfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
      rm -rf $HOME/.gtkrc-2.0
    '';
  };
}
