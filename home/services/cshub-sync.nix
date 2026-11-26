{ pkgs, ... }:

let
  cshubPkg = import ../../tools/cshub { inherit pkgs; };
in
{
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
