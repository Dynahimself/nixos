{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    tailscale
    cloudflared
    proton-vpn
    wireguard-tools
    filezilla
  ];
}
