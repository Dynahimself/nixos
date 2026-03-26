{
  description = "NixOS config with Zen browser, Catppuccin, and Neovim Nightly";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # 1. Added Neovim Nightly Overlay Input
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      zen-browser,
      catppuccin,
      home-manager,
      neovim-nightly-overlay,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix

          # 2. Apply the overlay globally
          {
            nixpkgs.overlays = [
              neovim-nightly-overlay.overlays.default
            ];
          }

          {
            environment.systemPackages = [
              zen-browser.packages.${system}.default
            ];
          }

          catppuccin.nixosModules.catppuccin
          home-manager.nixosModules.home-manager

          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.dyna = {
                imports = [
                  ./home.nix
                  catppuccin.homeModules.catppuccin
                ];
              };
            };
          }
        ];
      };
    };
}
