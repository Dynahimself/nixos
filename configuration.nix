# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').

{ config, pkgs, ... }:
{

  # Catppuccin
  catppuccin.enable = true;
  catppuccin.cursors.enable = true;

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Crucial for running 32-bit games (like Wine/Proton)
  };

  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = [ "nvidia" ];

  services.tailscale.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.networkmanager.enable = true;

  time.timeZone = "America/New_York";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # Enable X11
  services.xserver.enable = true;

  # Display Manager - SDDM with session selection at login
  services.displayManager.sddm.enable = true;

  # KDE Plasma as fallback session
  services.desktopManager.plasma6.enable = true;

  # bspwm - primary tiling WM
  services.xserver.windowManager.bspwm.enable = true;

  #Hyprland
  programs.hyprland.enable = true;

  # xdg-portal for screen sharing, file pickers, etc.
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    glibc
    libaio
    stdenv.cc.cc
    zlib
    openssl
    libxml2
    curl
  ];

  services.envfs.enable = true;

  services.printing.enable = true;
  hardware.keyboard.zsa.enable = true;

  # Sound with pipewire
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  programs.zsh = {
    enable = true;
  };

  # User account
  users.users.dyna = {
    isNormalUser = true;
    description = "Dyna";
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  programs.firefox.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports for Source Dedicated Server
    extraCompatPackages = [
      pkgs.proton-ge-bin
    ];

    # Enable Gamescope (the micro-compositor used on the Steam Deck)
    gamescopeSession.enable = true;
  };

  # Optimize system performance for gaming on demand
  programs.gamemode.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    wget
    curl
    btop
    hyprpanel
    tree
    unzip
    zip
    dbeaver-bin
    python313Packages.influxdb-client
    picom-pijulius
    tailscale
    starship
    zathura
    protonvpn-gui
    wireguard-tools
    zsh
    filezilla
    gnumake
    discord
    oh-my-zsh
    sioyek
    wl-clipboard
    fastfetch
    lutris
    wineWowPackages.yabridge
    winetricks
    nix-output-monitor
    catppuccin-cursors.mochaDark
    keymapp
    zoxide
    broot
    eza
    anki
    rofi-calc
    rofi-systemd
    rofi-network-manager
    unrar
    dust
    duf
    sd
    delta
    gh
    asdf
    github-copilot-cli
    aichat
    mods
    lazydocker
    nixfmt-rfc-style
    k9s
    fx
    glow
    pay-respects
    hyprland
    egl-wayland
    hyprpaper
    waybar
    hyprlock
    xdg-desktop-portal-hyprland
    flameshot
    brightnessctl
    ntfs3g
    hypridle
    wireplumber
    linuxKernel.packages.linux_zen.system76

    # --- bspwm stack ---
    bspwm
    sxhkd
    rofi
    polybar
    feh # wallpaper setter
    alacritty # terminal (or swap for kitty/wezterm)
    dunst # notification daemon
    maim # screenshots
    xclip # clipboard access
    pamixer # pulseaudio volume control
    playerctl # media player MPRIS control
    xdg-utils # xdg-open for default apps
    polkit_gnome # authentication agent (critical for GUI prompts)
    jq # useful for polybar scripts
    # ==========================================
    # 1. LSP SERVERS (Replaces Mason LSP installs)
    # ==========================================
    gcc
    clang-tools # nvim-jdtls, clangd_extensions.nvim
    gopls # neotest-golang
    rust-analyzer # rustaceanvim
    jdt-language-server # nvim-jdtls
    omnisharp-roslyn # omnisharp-extended-lsp.nvim

    # ==========================================
    # 2. DEBUG ADAPTERS (Replaces Mason DAP installs)
    # ==========================================
    delve # nvim-dap-go (Go debugger)
    netcoredbg

    # ==========================================
    # 3. TEST RUNNERS (Required by neotest adapters)
    # ==========================================
    go # neotest-golang
    zig # neotest-zig
    dotnet-sdk_8 # neotest-vstest (.NET testing)
    php # neotest-pest, neotest-phpunit
    php.packages.composer # To actually install pest/phpunit globally if needed
    luajitPackages.luarocks

    # ==========================================
    # 4. CLI TOOLS (Shelled out to by plugins)
    # ==========================================
    ripgrep # grug-far.nvim, Telescope/LazyVim default
    fd # grug-far.nvim, Telescope/LazyVim default
    gh # CopilotChat.nvim (GitHub CLI)
    cmake # cmake-tools.nvim
    cargo # crates.nvim, rustaceanvim
    rustc # rustaceanvim
    nodejs # markdown-preview.nvim (uses a local node server)

    # ==========================================
    # 5. LANGUAGES / MISC (Native dependencies)
    # ==========================================
    jdk # nvim-jdtls (Java runtime)
    typst # typst-preview.nvim
    lua
    python315
    fzf
    lazygit
    zellij
    copilot-language-server
    oracle-instantclient
    python313Packages.oracledb
    nodePackages.typescript-language-server # For JS/TS
    nodePackages.vscode-langservers-extracted # For CSS
    vscode
  ];

  environment.shells = with pkgs; [
    zsh
    bash
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig.defaultFonts = {
    monospace = [ "JetBrainsMono Nerd Font" ];
  };

  system.stateVersion = "25.11";
}
