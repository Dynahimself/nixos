{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    zsh
    oh-my-zsh
    starship
    zellij
  ];
}
