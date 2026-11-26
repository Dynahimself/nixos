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
        ./system
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
                ./home
                ./nixvim
                nixvim.homeModules.nixvim
                catppuccin.homeModules.catppuccin
                spicetify-nix.homeManagerModules.default
              ];
            };
          };
        }
      ];
    in
    {
      nixosConfigurations = {
        laptop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = commonModules ++ [
            ./hosts/laptop
          ];
        };

        desktop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = commonModules ++ [
            ./hosts/desktop
          ];
        };

        wsl = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./hosts/wsl
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
                    ./home/wsl.nix
                    ./nixvim
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
          modules = [ ./hosts/nas ];
        };

        pi = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit inputs; };
          modules = [ ./hosts/pi ];
        };
      };
    };
}
