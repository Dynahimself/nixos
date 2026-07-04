# System packages — split from configuration.nix for organization.
# Imported via configuration.nix: imports = [ ./packages.nix ];
{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    # =====================================================
    # Core CLI
    # =====================================================
    wget
    curl
    tree
    unzip
    zip
    unrar
    parted
    ntfs3g
    gnumake
    filezilla
    usbimager
    nix-output-monitor
    nixfmt-rfc-style

    # =====================================================
    # System utilities
    # =====================================================
    btop
    duf
    dust
    sd
    delta
    fx
    glow
    eza
    zoxide
    broot
    fzf
    pay-respects
    busybox
    openldap
    ventoy-full-qt

    # =====================================================
    # Shell
    # =====================================================
    zsh
    oh-my-zsh
    starship
    zellij

    # =====================================================
    # Networking / VPN
    # =====================================================
    tailscale
    cloudflared
    proton-vpn
    wireguard-tools

    # =====================================================
    # Git / Dev tools
    # =====================================================
    gh
    lazygit
    lazydocker
    k9s
    asdf
    github-copilot-cli
    copilot-language-server

    # =====================================================
    # AI / LLM CLI
    # =====================================================
    aichat
    mods

    # =====================================================
    # Hyprland ecosystem
    # =====================================================
    hyprland
    hyprpanel
    hyprpaper
    hyprlock
    hypridle
    hyprshot
    xdg-desktop-portal-hyprland
    egl-wayland
    waybar
    wlogout
    wl-clipboard
    wireplumber
    brightnessctl
    flameshot
    picom-pijulius

    # =====================================================
    # bspwm stack
    # =====================================================
    bspwm
    sxhkd
    rofi
    rofi-calc
    rofi-systemd
    rofi-network-manager
    polybar
    feh
    alacritty
    dunst
    maim
    xclip
    pamixer
    playerctl
    xdg-utils
    polkit_gnome
    jq

    # =====================================================
    # Desktop apps
    # =====================================================
    discord
    gimp
    dbeaver-bin
    zathura
    sioyek
    anki
    deluge-gtk
    prismlauncher
    lutris
    vscode

    # =====================================================
    # Hardware tools
    # =====================================================
    blueman
    razergenie
    piper
    input-remapper
    keymapp
    polychromatic

    # =====================================================
    # Audio
    # =====================================================
    pavucontrol

    # =====================================================
    # Theming
    # =====================================================
    catppuccin-cursors.mochaDark

    # =====================================================
    # Activity tracking
    # =====================================================
    activitywatch
    python313Packages.influxdb-client

    # =====================================================
    # Gaming
    # =====================================================
    wineWowPackages.yabridge
    hydralauncher
    winetricks

    # =====================================================
    # Neovim — LSP servers
    # =====================================================
    gcc
    clang-tools
    gopls
    rust-analyzer
    jdt-language-server
    omnisharp-roslyn
    typescript-language-server
    vscode-langservers-extracted

    # =====================================================
    # Neovim — Debug adapters
    # =====================================================
    delve
    netcoredbg

    # =====================================================
    # Neovim — Test runners / Language runtimes
    # =====================================================
    go
    zig
    dotnet-sdk_8
    php
    php.packages.composer
    luajitPackages.luarocks
    temurin-bin-25

    # =====================================================
    # Neovim — CLI tools (shelled out to by plugins)
    # =====================================================
    ripgrep
    fd
    cmake
    cargo
    rustc
    nodejs

    # =====================================================
    # Languages / Misc
    # =====================================================
    lua
    python311
    typst
    sqlcl
    luajitPackages.plenary-nvim
    oracle-instantclient
    python313Packages.oracledb

    # =====================================================
    # Kernel packages
    # =====================================================
    linuxKernel.packages.linux_zen.system76

    # =====================================================
    # Screenshots / capture
    # =====================================================
    snipaste
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig.defaultFonts = {
    monospace = [ "JetBrainsMono Nerd Font" ];
  };

  environment.shells = with pkgs; [
    zsh
    bash
  ];

  users.users.dyna = {
    packages = with pkgs; [
      kdePackages.kate
    ];
  };
}
