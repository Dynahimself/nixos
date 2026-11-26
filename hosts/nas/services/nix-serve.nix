{ pkgs, ... }:

{
  # ---- Nix binary cache server (serves /nix/store to the fleet on :5000) ----
  services.nix-serve = {
    enable = true;
    package = pkgs.nix-serve-ng;
    port = 5000;
    secretKeyFile = "/var/cache-priv-key.pem";
  };
}
