{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    discord
    gimp
    zathura
    sioyek
    anki
    deluge-gtk
    kdePackages.kdenlive
    mpv
    snipaste
    libreoffice-qt
    hunspellDicts.en-us
    hunspellDicts.fr-moderne
    pavucontrol
    waydroid
    catppuccin-cursors.mochaDark
    # activitywatch: broken in nixpkgs (peewee>=4)
    # activitywatch
  ];
}
