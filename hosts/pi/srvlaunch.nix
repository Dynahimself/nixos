{ ... }:

{
  # srvlaunch panel (same launcher as the NAS)
  services.srvlaunch = {
    enable = true;
    http_port = 8300;
    apps = {
      hermes = {
        displayName = "Hermes";
        url = "http://100.68.54.112:8200";
        units = [ ]; # hermes.service created on pi-NixOS day
        color = "#f5c2e7";
      };
      chub-gems = {
        displayName = "Chub Gems";
        url = "http://100.68.54.112:5123";
        units = [ ];
        color = "#cba6f7";
      };
    };
  };
}
