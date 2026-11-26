{ lib, ... }:

{
  # ---- media group + dirs (hardlink-friendly: qbit downloads, arrs move, jellyfin reads) ----
  users.groups.media = { };
  systemd.tmpfiles.rules = [
    "d /srv/media 2775 root media -"
    "d /srv/media/movies 2775 root media -"
    "d /srv/media/tv 2775 root media -"
    "d /srv/media/downloads 2775 root media -"
    "d /srv/media/downloads/complete 2775 root media -"
    "d /srv/immich 2775 root media -"
    "d /srv/immich/library 2775 root media -"
    "d /srv/backups/pi 2775 dyna media -"
  ];

  # one umbrella target = one click starts the whole chain
  systemd.targets.media-stack = {
    description = "Media stack (jellyfin sonarr radarr prowlarr seerr qbittorrent)";
    wants = [
      "jellyfin.service"
      "sonarr.service"
      "radarr.service"
      "prowlarr.service"
      "seerr.service"
      "qbittorrent.service"
    ];
    wantedBy = lib.mkForce [ ];
  };
}
