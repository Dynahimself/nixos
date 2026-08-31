# System packages — split from configuration.nix for organization.
# Imported via configuration.nix: imports = [ ./packages.nix ];
{ pkgs, ... }:

{
  nixpkgs.config.permittedInsecurePackages = [ "ventoy-full-qt" ];

  environment.systemPackages = with pkgs; [
    # =====================================================
    # Core CLI
    # =====================================================
    wget
    curl
    tree
    unzip
    tldr
    zip
    fastfetch
    unrar
    parted
    ntfs3g
    gnumake
    filezilla
    protontricks
    appimage-run
    python313Packages.pycryptodomex
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
    python314Packages.pmsensor
    fx
    glow
    eza
    zoxide
    broot
    fzf
    pay-respects
    busybox
    openldap

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
    hyprpaper
    hyprlock
    hypridle
    hyprshot
    xdg-desktop-portal-hyprland
    networkmanagerapplet
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
    # input-remapper
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
    dotnet-sdk_10
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
    scrcpy
    android-tools # adb for scrcpy

    # =====================================================
    # Languages / Misc
    # =====================================================
    lua
    python311
    typst
    sqlcl
    luajitPackages.plenary-nvim
    waydroid
    sqlite
    android-studio
    oracle-instantclient
    python313Packages.oracledb
    kdePackages.kdenlive
    mpv

    # =====================================================
    # Kernel packages
    # =====================================================
    linuxKernel.packages.linux_zen.system76

    # =====================================================
    # Screenshots / capture
    # =====================================================
    snipaste

    #AMD
    amdgpu_top
    corectrl
    vulkan-tools
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
