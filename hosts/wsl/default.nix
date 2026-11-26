{ config, pkgs, ... }:

{

  imports = [ ../../system/core ];

  wsl.enable = true;
  wsl.defaultUser = "dyna";
  # UID is 1001 in WSL rootfs
  users.users.dyna.uid = 1001;

  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = false;
  fileSystems."/".device = "/dev/null";
  fileSystems."/".fsType = "ext4";

  environment.shells = with pkgs; [ bash zsh ];
  # Disable Python docs (sphinx build failure in nixpkgs)
  documentation.enable = false;

  environment.systemPackages = with pkgs; [
    wget curl tree unzip zip tldr fastfetch jq bc

    gcc clang-tools gopls rust-analyzer
    typescript-language-server vscode-langservers-extracted
    omnisharp-roslyn jdt-language-server

    go zig dotnet-sdk_10 nodejs python311 lua

    ripgrep fd cmake cargo rustc nh nvd

    gh lazygit delta

    bash zsh starship zellij yazi atuin direnv

    btop duf dust sd eza zoxide fzf
  ];
}
