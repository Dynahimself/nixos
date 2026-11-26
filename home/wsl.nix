{ ... }:

{
  imports = [
    ./theming/catppuccin.nix
    ./services/scripts-wsl.nix
    ./programs/git.nix
    ./programs/ssh.nix
    ./programs/zsh/wsl.nix
    ./programs/starship.nix
    ./programs/bat.nix
    ./programs/delta.nix
    ./programs/fzf.nix
    ./programs/atuin.nix
    ./programs/direnv.nix
    ./programs/zoxide.nix
    ./programs/yazi.nix
    ./programs/lazygit.nix
    ./programs/zellij.nix
    ./programs/fastfetch.nix
  ];

  home.username = "dyna";
  home.homeDirectory = "/home/dyna";
  home.stateVersion = "25.11";
  home.sessionPath = [ "$HOME/.local/bin" ];

  # Disable Hyprland LSP stubs on WSL
  dyna.nixvim = {
    enable = true;
    hyprStubs = false;
  };
  programs.neovim.enable = false;
}
