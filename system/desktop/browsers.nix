{ pkgs, inputs, ... }:

{
  programs.firefox.enable = true;

  environment.systemPackages = [
    (pkgs.wrapFirefox inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.zen-browser-unwrapped {
      pname = "zen-browser";
      extraPolicies = import ../../modules/zen-policies.nix;
    })
  ];
}
