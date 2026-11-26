{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
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
    pamixer
    playerctl
    polkit_gnome
  ];
}
