{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    blueman
    razergenie
    piper
    # input-remapper
    keymapp
    polychromatic
    linuxKernel.packages.linux_zen.system76
  ];
}
