{ ... }:

{
  services.tailscale.enable = true;
  services.openssh.enable = true;
  networking.interfaces.eno1.wakeOnLan.enable = true;

  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.backend = "wpa_supplicant";
}
