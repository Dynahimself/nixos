{ config, pkgs, ... }:

{
  # WSL — full terminal dev environment, no GUI

  imports = [ ./base.nix ];

  # the actual NixOS-WSL module (without wsl.enable, no WSL system gets built)
  wsl.enable = true;
  wsl.defaultUser = "dyna";
  # dyna is really UID 1001 in the WSL filesystem (tarball nixos user owns 1000) —
  # without this pin, home-manager activation fails: UID is 1001, expected 1000
  users.users.dyna.uid = 1001;

  # WSL boot/filesystem (handled by WSL init, not a real bootloader)
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = false;
  fileSystems."/".device = "/dev/null";
  fileSystems."/".fsType = "ext4";

  environment.shells = with pkgs; [ bash zsh ];
  # Disable Python docs (sphinx build broken in nixpkgs)
  documentation.enable = false;

  # No GUI stuff — terminal dev workbench parity
  environment.systemPackages = with pkgs; [
    # Core CLI
    wget curl tree unzip zip tldr fastfetch jq bc

    # Dev tools
    gcc clang-tools gopls rust-analyzer
    typescript-language-server vscode-langservers-extracted
    omnisharp-roslyn jdt-language-server

    # Runtimes
    go zig dotnet-sdk_10 nodejs python311 lua

    # CLI tools
    ripgrep fd cmake cargo rustc nh nvd

    # Git
    gh lazygit delta

    # Shell & terminal UX
    bash zsh starship zellij yazi atuin direnv

    # System utilities
    btop duf dust sd eza zoxide fzf
  ];
}
