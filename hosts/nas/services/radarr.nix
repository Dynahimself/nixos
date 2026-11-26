{ lib, ... }:

{
  services.radarr = {
    enable = true;
    group = "media";
  };

  systemd.services.radarr.wantedBy = lib.mkForce [ ];
}
