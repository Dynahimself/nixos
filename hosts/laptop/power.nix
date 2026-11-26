{ ... }:

{
  # Lid switch behavior
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchDocked = "ignore";
  };

  powerManagement.enable = true;

  services.tlp = {
    enable = true;
    settings = {
      STOP_CHARGE_THRESH_BAT0 = 70;
    };
  };
}
