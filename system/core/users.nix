{ pkgs, ... }:

{
  users.users.dyna = {
    isNormalUser = true;
    description = "Dyna";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" ];
  };

  programs.zsh.enable = true;
}
