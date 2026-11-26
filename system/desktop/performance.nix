{ ... }:

{
  documentation.doc.enable = false;

  nix.settings.max-jobs = 6;
  nix.settings.cores = 0;

  swapDevices = [
    { device = "/var/lib/swapfile"; size = 32 * 1024; }
  ];
}
