{ pkgs, ... }:

let
  cshubPkg = import ../../tools/cshub { inherit pkgs; };
  mkScript = name:
    pkgs.writeShellScriptBin name (
      builtins.replaceStrings [ "#!/usr/bin/env bash\n" ] [ "" ] (
        builtins.readFile (../../dotfiles/scripts + "/${name}")
      )
    );
in
{
  home.packages = [ cshubPkg ] ++ map mkScript [
    "rofi-wifi"
    "rofi-fleet"
    "rofi-system"
    "rofi-wallpaper"
    "rofi-calc"
    "rofi-clip"
    "rofi-audio"
    "rofi-workbench"
    "rofi-cshub"
    "rofi-zen"
    "theme-accent"
    "study-mode"
    "game-mode"
    "rofi-binds"
    "quick-note"
    "cshub-term-capture"
    "cshub-bar"
    "fleet"
    "fleet-bar"
    "fleet-clip"
    "clock-bar"
    "hw-temp-bar"
    "mode-bar"
    "motion-coach"
    "battery-alert"
    "nas-cache-push"
  ];
}
