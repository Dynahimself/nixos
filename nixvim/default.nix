{ config, lib, pkgs, ... }:

let
  cfg = config.dyna.nixvim;
in
{
  options.dyna.nixvim = {
    enable = lib.mkEnableOption "Nixvim editor";
    hyprStubs = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include Hyprland Lua LSP stubs";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
      _module.args.hmPkgs = pkgs;

      imports = [
        ./core
        ./plugins
        (import ./plugins/lsp/servers.nix { inherit pkgs; hyprStubs = cfg.hyprStubs; })
      ];
    };
  };
}
