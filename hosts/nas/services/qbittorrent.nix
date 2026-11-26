{ lib, ... }:

{
  # ---- qBittorrent (headless) ----
  services.qbittorrent = {
    enable = true;
    group = "media";
    webuiPort = 8080;
    torrentingPort = 51413;
    serverConfig = {
      LegalNotice.Accepted = true;
      Preferences.WebUI = {
        Username = "dyna";
        Password_PBKDF2 = "@ByteArray(cinSuNPibHNuXw/1BboPUw==:kDe+WI1ZjvwNxMEig3QQReE2GBgehGaeqC7qabBvA6A0sx26ag9SQwztLDNWpeJm+eVKBJM4NObxhZXk+0gJOQ==)";
      };
      BitTorrent.Session = {
        DefaultSavePath = "/srv/media/downloads";
        TempPathEnabled = true;
        TempPath = "/srv/media/downloads/incomplete";
        PortEnabled = true;
      };
    };
  };

  systemd.services.qbittorrent.wantedBy = lib.mkForce [ ];
}
