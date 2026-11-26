{ pkgs, ... }:

{
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    glibc
    libaio
    stdenv.cc.cc
    zlib
    openssl
    libxml2
    curl
  ];

  services.envfs.enable = true;
}
