{ ... }:

{
  imports = [
    ./locale.nix
    ./nix.nix
    ./users.nix
    ./languagetool.nix
  ];

  system.stateVersion = "25.11";
}
