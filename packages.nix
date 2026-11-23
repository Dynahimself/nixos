{ pkgs, ... }:

{
  nixpkgs.config.permittedInsecurePackages = [ "ventoy-full-qt" ];

  environment.systemPackages = with pkgs; [
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
    nixfmt

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

    zsh
    oh-my-zsh
    starship
    zellij

    tailscale
    cloudflared
    proton-vpn
    wireguard-tools

    gh
    lazygit
    lazydocker
    k9s
    asdf
    github-copilot-cli
    copilot-language-server

    aichat
    mods

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

    (rofi.override { plugins = [ rofi-calc ]; })
    libqalculate
    libnotify
    rofi-systemd
    rofi-network-manager
    swaynotificationcenter
    cliphist
    swayosd
    awww
    satty
    wf-recorder
    tesseract
    slurp
    grim
    hyprsunset
    hyprpicker
    imagemagick
    cava
    nh
    nvd
    xclip
    pamixer
    playerctl
    xdg-utils
    polkit_gnome
    jq

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

    blueman
    razergenie
    piper
    # input-remapper
    keymapp
    polychromatic

    pavucontrol

    catppuccin-cursors.mochaDark

    # activitywatch: broken in nixpkgs (peewee>=4)
    # activitywatch
    python313Packages.influxdb-client

    wineWow64Packages.yabridge
    hydralauncher
    winetricks

    gcc
    clang-tools
    gopls
    rust-analyzer
    jdt-language-server
    omnisharp-roslyn
    typescript-language-server
    vscode-langservers-extracted

    delve
    netcoredbg

    go
    zig
    dotnet-sdk_10
    php
    php.packages.composer
    luajitPackages.luarocks
    temurin-bin-25

    ripgrep
    fd
    cmake
    cargo
    rustc
    nodejs
    scrcpy
    android-tools

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

    linuxKernel.packages.linux_zen.system76

    snipaste

    amdgpu_top
    corectrl
    vulkan-tools

    libreoffice-qt
    hunspellDicts.en-us
    hunspellDicts.fr-moderne
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
