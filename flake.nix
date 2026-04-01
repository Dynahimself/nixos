{
  description = "NixOS config with Zen browser, Catppuccin, and Neovim Nightly";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";
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
      ...
    }@inputs:
    let
      system = "x86_64-linux";

      pkgs = nixpkgs.legacyPackages.${system};
      # Defining common modules to avoid repetition
      commonModules = [
        ./configuration.nix
        catppuccin.nixosModules.catppuccin
        home-manager.nixosModules.home-manager
        {
          # Apply the Neovim Nightly Overlay
          nixpkgs.overlays = [ neovim-nightly-overlay.overlays.default ];

          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            backupFileExtension = "backup";
            extraSpecialArgs = { inherit inputs; };
            users.dyna = {
              imports = [
                ./home.nix
                catppuccin.homeModules.catppuccin
                spicetify-nix.homeManagerModules.default
              ];
            };
          };

          # Install Zen Browser via the flake package
          environment.systemPackages = [
            zen-browser.packages.${system}.default
          ];
        }
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
      };
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          gcc
          clang-tools
          glibc.dev
        ];
      };
    };
}
