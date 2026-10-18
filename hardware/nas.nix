# TerraMaster F2-425 — headless media/storage server profile
{ config, pkgs, lib, ... }:

{
  imports = [
    ../server-base.nix
    ./nas-hardware-configuration.nix
    ../modules/srvlaunch.nix
  ];

  system.stateVersion = "25.05";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "nas";
  networking.useDHCP = true;
  # public resolvers: qbittorrent's DNS gets marked into the tunnel (LAN resolver unreachable there)
  networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];

  boot.kernelModules = [ "coretemp" ];

  services.tailscale.enable = true;
  services.smartd.enable = true;
  virtualisation.docker.enable = true;

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
  ];

  # ---- Jellyfin ----
  services.jellyfin = {
    enable = true;
    group = "media";
  };

  # ---- Sonarr / Radarr / Prowlarr ----
  services.sonarr = {
    enable = true;
    group = "media";
  };
  services.radarr = {
    enable = true;
    group = "media";
  };
  services.prowlarr.enable = true;

  # ---- Jellyseerr (upstream module name: seerr) ----
  services.seerr.enable = true;

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
        Password_PBKDF2 = "@ByteArray(MTAwMDAwOnZtWSt6czJxTEJCNk9pNDNzUzZtOUE9PTphK1J1R1AyaHE5cVJBMEl5bmFCSHBMK29OeVJSZkRMU2t1OGpuczN3cEFxMEx5bWRVMDZjbWpwQXBtdWZCcmJYQVRnQ0QrZklCcnBWRGd0cUV5RmMvUT09)";
      };
      BitTorrent.Session = {
        DefaultSavePath = "/srv/media/downloads";
        TempPathEnabled = true;
        TempPath = "/srv/media/downloads/incomplete";
        PortEnabled = true;
      };
    };
  };

  # ---- nothing auto-starts: the panel (srvlaunch) starts the stack on demand ----
  systemd.services.sonarr.wantedBy = lib.mkForce [ ];
  systemd.services.radarr.wantedBy = lib.mkForce [ ];
  systemd.services.prowlarr.wantedBy = lib.mkForce [ ];
  systemd.services.seerr.wantedBy = lib.mkForce [ ];
  systemd.services.jellyfin.wantedBy = lib.mkForce [ ];
  systemd.services.qbittorrent.wantedBy = lib.mkForce [ ];

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

  # ---- Immich (docker; ML disabled — N5095 has no AVX, onnxruntime would SIGILL) ----
  virtualisation.oci-containers.backend = "docker";
  virtualisation.oci-containers.containers = {
    immich-server = {
      image = "ghcr.io/immich-app/immich-server:release";
      ports = [ "2283:2283" ];
      volumes = [
        "/srv/immich/library:/usr/src/app/upload"
        "/etc/localtime:/etc/localtime:ro"
      ];
      environment = {
        IMMICH_VERSION = "release";
        DB_HOSTNAME = "immich-db";
        DB_USERNAME = "immich";
        DB_PASSWORD = "immich";
        DB_DATABASE_NAME = "immich";
        REDIS_HOSTNAME = "immich-redis";
        IMMICH_MACHINE_LEARNING_ENABLED = "false";
      };
      extraOptions = [ "--network=immich" ];
      autoStart = false;
    };
    immich-redis = {
      image = "docker.io/library/redis:6.2-alpine";
      extraOptions = [ "--network=immich" ];
      autoStart = false;
    };
    immich-db = {
      image = "ghcr.io/immich-app/postgres:16-vectorchord0.4.3-pgvectors0.2.0";
      environment = {
        POSTGRES_PASSWORD = "immich";
        POSTGRES_USER = "immich";
        POSTGRES_DB = "immich";
      };
      volumes = [
        "/srv/immich/db:/var/lib/postgresql/data"
      ];
      extraOptions = [ "--network=immich" ];
      autoStart = false;
    };
  };
  # ordering for the immich trio (docker run has no --depends-on; that's compose-only)
  systemd.services.docker-immich-network = {
    description = "Ensure docker network 'immich' exists";
    after = [ "docker.service" ];
    wantedBy = [ "docker-immich-db.service" "docker-immich-redis.service" ];
    before = [ "docker-immich-db.service" "docker-immich-redis.service" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.docker}/bin/docker network create immich || true";
      RemainAfterExit = true;
    };
  };
  systemd.services.docker-immich-db = {
    after = [ "docker-immich-network.service" ];
    wants = [ "docker-immich-network.service" ];
  };
  systemd.services.docker-immich-redis = {
    after = [ "docker-immich-network.service" ];
    wants = [ "docker-immich-network.service" ];
  };
  systemd.services.docker-immich-server = {
    after = [ "docker-immich-db.service" "docker-immich-redis.service" "docker-immich-network.service" ];
    wants = [ "docker-immich-db.service" "docker-immich-redis.service" ];
  };

  # ---- ProtonVPN (split tunnel: only qbittorrent traffic goes through wg0) ----
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  systemd.services.protonvpn-wg0 = {
    description = "ProtonVPN wg0 (split tunnel, qbittorrent only)";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ iproute2 iptables wireguard-tools ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "wg0-up" ''
        key=$(cat /etc/protonvpn/privatekey)
        cat > /run/wg0.conf <<EOF
        [Interface]
        PrivateKey = $key
        Table = off
        FwMark = 4242
        Address = 10.2.0.2/32
        MTU = 1420

        [Peer]
        PublicKey = R0J2HK9bYV4Ww6tMk76hiTwiWbC6JvxqhvSNeO4tIhg=
        AllowedIPs = 0.0.0.0/0
        Endpoint = 151.243.141.5:51820
        PersistentKeepalive = 25
        EOF
        chmod 600 /run/wg0.conf
        wg-quick up /run/wg0.conf
        ip route add default dev wg0 table 100
        ip rule add to 151.243.141.5 lookup main priority 99
        ip rule add fwmark 51820 table 100 priority 100
        iptables -t mangle -A OUTPUT -m owner --uid-owner qbittorrent -j MARK --set-mark 51820
      '';
      ExecStop = pkgs.writeShellScript "wg0-down" ''
        iptables -t mangle -D OUTPUT -m owner --uid-owner qbittorrent -j MARK --set-mark 51820 2>/dev/null || true
        ip rule del fwmark 51820 table 100 2>/dev/null || true
        ip rule del to 151.243.141.5 lookup main 2>/dev/null || true
        wg-quick down /run/wg0.conf 2>/dev/null || true
      '';
    };
  };

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

  networking.firewall.enable = false; # LAN + tailscale only; panel on 8300
}
