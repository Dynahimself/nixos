{ ... }:

{
  # ---- launcher panel ----
  services.srvlaunch = {
    enable = true;
    http_port = 8300;
    apps = {
      media-stack = {
        displayName = "Media Stack";
        url = "http://nas:5055";
        units = [ "media-stack.target" ];
        color = "#f5c2e7";
      };
      jellyfin = {
        displayName = "Jellyfin";
        url = "http://nas:8096";
        units = [ "jellyfin.service" ];
        color = "#cba6f7";
      };
      sonarr = {
        displayName = "Sonarr";
        url = "http://nas:8989";
        units = [ "sonarr.service" ];
        color = "#89dceb";
      };
      radarr = {
        displayName = "Radarr";
        url = "http://nas:7878";
        units = [ "radarr.service" ];
        color = "#f9e2af";
      };
      prowlarr = {
        displayName = "Prowlarr";
        url = "http://nas:9696";
        units = [ "prowlarr.service" ];
        color = "#94e2d5";
      };
      jellyseerr = {
        displayName = "Jellyseerr";
        url = "http://nas:5055";
        units = [ "seerr.service" ];
        color = "#f5e0dc";
      };
      qbittorrent = {
        displayName = "qBittorrent";
        url = "http://nas:8080";
        units = [ "qbittorrent.service" ];
        color = "#a6e3a1";
      };
      immich = {
        displayName = "Immich";
        url = "http://nas:2283";
        units = [ "docker-immich-server.service" ];
        color = "#89b4fa";
      };
    };
  };
}
