{ ... }:

{
  # Note: ./servers.nix is imported directly from ../../default.nix with hyprStubs
  imports = [
    ./roslyn.nix
    ./rustaceanvim.nix
    ./jdtls.nix
    ./lazydev.nix
    ./inc-rename.nix
    ./otter.nix
    ./conform.nix
    ./lint.nix
  ];
}
