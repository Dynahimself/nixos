{ ... }:

{
  services.desktopManager.plasma6.enable = true;
  # Disable power-profiles-daemon (conflicts with TLP on laptop)
  services.power-profiles-daemon.enable = false;
}
