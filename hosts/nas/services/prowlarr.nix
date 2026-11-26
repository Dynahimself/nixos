{ lib, ... }:

{
  services.prowlarr.enable = true;
  systemd.services.prowlarr.wantedBy = lib.mkForce [ ];
}
