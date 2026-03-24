{
  description = "NixOS config with Zen browser and Catppuccin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

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

  outputs = { self, nixpkgs, zen-browser, catppuccin, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    lib = nixpkgs.lib;

    nvim-config = builtins.fetchTarball {
      url = "https://github.com/Dynahimself/nvim/archive/refs/heads/main.tar.gz";
      sha256 = "1mrhlzcvmcx3a2vy76f31ry721ykv91a7ilng1ma9jhr4gm4i2lz";
    };
  in {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      inherit system;

      modules = [
        ./configuration.nix

        {
          environment.systemPackages = [
            zen-browser.packages.${system}.default
          ];
        }

        catppuccin.nixosModules.catppuccin
        home-manager.nixosModules.home-manager

        # Correct home-manager configuration 👇
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = { inherit nvim-config; };
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
