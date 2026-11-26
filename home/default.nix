{ ... }:

{
  imports = [
    ./theming
    ./desktop
    ./services
    ./programs/ghostty.nix
    ./programs/kitty.nix
    ./programs/zen.nix
    ./programs/spicetify.nix
    ./programs/zathura.nix
    ./programs/zsh
    ./programs/starship.nix
    ./programs/git.nix
    ./programs/ssh.nix
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

  dyna.nixvim.enable = true;
  programs.neovim.enable = false;

  home.username = "dyna";
  home.homeDirectory = "/home/dyna";
  home.stateVersion = "25.11";
  home.sessionPath = [ "$HOME/.local/bin" ];

  programs.ssh.settings."laptop-win dyna-4" = {
    hostname = "100.110.58.123";
    user = "olivi";
  };
}
