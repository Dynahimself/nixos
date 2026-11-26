{ pkgs, ... }:

let
  batteryAlert = pkgs.writeShellScriptBin "battery-alert" (
    builtins.replaceStrings [ "#!/usr/bin/env bash\n" ] [ "" ] (
      builtins.readFile ../../dotfiles/scripts/battery-alert
    )
  );
in
{
  systemd.user.services.battery-alert = {
    Unit.Description = "Low battery notification check (20% / 10%)";
    Service = {
      Type = "oneshot";
      ExecStart = "${batteryAlert}/bin/battery-alert";
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
