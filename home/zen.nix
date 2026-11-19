{ pkgs, ... }:

let
  catppuccin-zen = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "zen-browser";
    rev = "main";
    sha256 = "5A57Lyctq497SSph7B+ucuEyF1gGVTsuI3zuBItGfg4=";
  };
  themePath = "${catppuccin-zen}/themes/Mocha/Mauve";
  profileName = "dynas";
in
{
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

  home.file.".zen/${profileName}/chrome/userChrome.css".source = "${themePath}/userChrome.css";
  home.file.".zen/${profileName}/chrome/userContent.css".source = ../dotfiles/userContent.css;
  home.file.".zen/${profileName}/chrome/zen-logo-mocha.svg".source = "${themePath}/zen-logo-mocha.svg";

  home.file.".zen/${profileName}/user.js".text = ''
    user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);
    user_pref("browser.tabs.drawInTitlebar", true);
    user_pref("browser.compactmode.show", true);
    user_pref("zen.view.compact", false);
    user_pref("browser.startup.homepage", "http://100.68.54.112:8210");
  '';

  home.file.".zen/${profileName}/zen-themes.json".source = ../dotfiles/zen-themes.json;
}
