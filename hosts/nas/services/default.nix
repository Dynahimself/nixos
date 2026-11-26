{ ... }:

{
  imports = [
    ./media-dirs.nix
    ./jellyfin.nix
    ./sonarr.nix
    ./radarr.nix
    ./prowlarr.nix
    ./jellyseerr.nix
    ./qbittorrent.nix
    ./immich.nix
    ./protonvpn.nix
    ./nix-serve.nix
    ./srvlaunch.nix
  ];
}
