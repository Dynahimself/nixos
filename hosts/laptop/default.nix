# hosts/laptop/default.nix
{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./boot.nix
    ./nvidia.nix
    ./power.nix
    ./monitor.nix
  ];

  networking.hostName = "laptop";
  console.useXkbConfig = true;
}
