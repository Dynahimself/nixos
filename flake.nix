{
  description = "NixOS config with Zen browser, Catppuccin, and Neovim Nightly";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";
    nixos-wsl.url = "github:nix-community/NixOS-WSL/main";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      catppuccin,
      home-manager,
      zen-browser,
      spicetify-nix,
      neovim-nightly-overlay,
      nixvim,
      nixos-wsl,
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      commonModules = [
        ./configuration.nix
        catppuccin.nixosModules.catppuccin
        home-manager.nixosModules.home-manager
        {
          nixpkgs.overlays = [ neovim-nightly-overlay.overlays.default ];

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = { inherit inputs; };
            users.dyna = {
              imports = [
                ./home.nix
                ./nixvim.nix
                nixvim.homeModules.nixvim
                catppuccin.homeModules.catppuccin
                spicetify-nix.homeManagerModules.default
              ];
            };
          };

        }
        (
          { pkgs, ... }:
          {
            environment.systemPackages = [
              (pkgs.wrapFirefox zen-browser.packages.${system}.zen-browser-unwrapped {
                pname = "zen-browser";
                extraPolicies = import ./modules/zen-policies.nix;
              })
            ];
          }
        )
      ];
    in
    {
      nixosConfigurations = {
        laptop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = commonModules ++ [
            ./hardware/laptop.nix
            ./hardware/laptop-hardware-configuration.nix
          ];
        };

        desktop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = commonModules ++ [
            ./hardware/desktop.nix
            ./hardware/desktop-hardware-configuration.nix
          ];
        };

        wsl = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./wsl.nix
            nixos-wsl.nixosModules.default
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                backupFileExtension = "backup";
                extraSpecialArgs = { inherit inputs; };
                users.dyna = {
                  imports = [
                    ./home-wsl.nix
                    ./nixvim.nix
                    nixvim.homeModules.nixvim
                    catppuccin.homeModules.catppuccin
                  ];
                };
              };
              nixpkgs.overlays = [ neovim-nightly-overlay.overlays.default ];
            }
          ];
        };

        nas = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [ ./hardware/nas.nix ];
        };

        pi = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit inputs; };
          modules = [ ./hardware/pi.nix ];
        };
      };
    };
}
