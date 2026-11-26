{ lib, ... }:

{
  # ---- Jellyseerr (upstream module name: seerr) ----
  services.seerr.enable = true;
  systemd.services.seerr.wantedBy = lib.mkForce [ ];
}
