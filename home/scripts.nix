{ pkgs, ... }:

let
  cshubPkg = import ../tools/cshub { inherit pkgs; };
  mkScript = name:
    pkgs.writeShellScriptBin name (
      builtins.replaceStrings [ "#!/usr/bin/env bash\n" ] [ "" ] (
        builtins.readFile (../dotfiles/scripts + "/${name}")
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

  systemd.user.services.cshub-sync = {
    Unit.Description = "CS Hub bidirectional Tailscale sync + deadline reminders";
    Service = {
      Type = "oneshot";
      ExecStart = "${cshubPkg}/bin/cshub sync --quiet --notify";
    };
  };

  systemd.user.timers.cshub-sync = {
    Unit.Description = "Sync CS Hub with Pi every 5 minutes (offline-safe)";
    Timer = {
      OnBootSec = "30s";
      OnUnitActiveSec = "5m";
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
