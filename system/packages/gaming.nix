{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    prismlauncher
    lutris
    hydralauncher
    wineWow64Packages.yabridge
    winetricks
    protontricks
    amdgpu_top
    corectrl
    vulkan-tools
  ];
}
