{ pkgs, ... }:

let
  mkScript = name:
    pkgs.writeShellScriptBin name (
      builtins.replaceStrings [ "#!/usr/bin/env bash\n" ] [ "" ] (
        builtins.readFile (../dotfiles/scripts + "/${name}")
      )
    );
in
{
  home.packages = map mkScript [
    "rofi-wifi"
    "rofi-fleet"
    "rofi-system"
    "rofi-wallpaper"
    "theme-accent"
    "study-mode"
    "game-mode"
    "rofi-binds"
    "quick-note"
    "cshub-term-capture"
    "cshub-bar"
    "fleet-bar"
    "battery-alert"
    "nas-cache-push"
  ];

  systemd.user.services.battery-alert = {
    Unit.Description = "Low battery notification check (20% / 10%)";
    Service = {
      Type = "oneshot";
      ExecStart = "${mkScript "battery-alert"}/bin/battery-alert";
    };
  };

  systemd.user.timers.battery-alert = {
    Unit.Description = "Check battery every 2 minutes";
    Timer = {
      OnBootSec = "1m";
      OnUnitActiveSec = "2m";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
