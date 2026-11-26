{ lib, ... }:

{
  # ---- Sonarr / Radarr / Prowlarr ----
  services.sonarr = {
    enable = true;
    group = "media";
  };

  systemd.services.sonarr.wantedBy = lib.mkForce [ ];
}
