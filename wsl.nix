{ config, pkgs, ... }:

{
  # WSL — minimal dev environment, no GUI

  imports = [ ./base.nix ];

  # WSL boot/filesystem (handled by WSL init, not a real bootloader)
  boot.loader.grub.enable = false;
  boot.loader.systemd-boot.enable = false;
  fileSystems."/".device = "/dev/null";
  fileSystems."/".fsType = "ext4";

  # Disable Python docs (sphinx build broken in nixpkgs)
  documentation.enable = false;

  # No GUI stuff — just dev tools
  environment.systemPackages = with pkgs; [
    # Core CLI
    wget curl tree unzip zip tldr fastfetch

    # Dev tools
    gcc clang-tools gopls rust-analyzer
    typescript-language-server vscode-langservers-extracted
    omnisharp-roslyn jdt-language-server

    # Runtimes
    go zig dotnet-sdk_10 nodejs python311 lua

    # CLI tools
    ripgrep fd cmake cargo rustc

    # Git
    gh lazygit

    # Shell
    zsh starship zellij

    # System utilities
    btop duf dust sd eza zoxide fzf
  ];
}
