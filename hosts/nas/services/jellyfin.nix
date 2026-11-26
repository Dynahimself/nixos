{ lib, ... }:

{
  # ---- Jellyfin ----
  services.jellyfin = {
    enable = true;
    group = "media";
  };

  systemd.services.jellyfin.wantedBy = lib.mkForce [ ];
}
