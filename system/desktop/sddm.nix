{ ... }:

{
  catppuccin.sddm.enable = true;
  catppuccin.sddm.flavor = "mocha";

  services.displayManager.sddm.enable = true;
  services.displayManager.sddm.wayland.enable = false;
  services.displayManager.sddm.settings.General.InputMethod = "";
}
