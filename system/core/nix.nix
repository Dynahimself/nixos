{ ... }:

{
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    trusted-users = [ "root" "dyna" ];
    extra-substituters = [ "http://100.97.162.110:5000?priority=30" ];
    extra-trusted-public-keys = [ "nas-cache-1:cJXZP/MSyt9AvkbMiXX0SrbkZqt9zU1qlq0OIkwyCcU=" ];
    connect-timeout = 3;
    fallback = true;
  };
  nixpkgs.config.allowUnfree = true;

  # Skip openldap tests
  nixpkgs.overlays = [
    (final: prev: {
      openldap = prev.openldap.overrideAttrs (oldAttrs: {
        doCheck = false;
      });
    })
  ];

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
  nix.optimise.automatic = true;
}
