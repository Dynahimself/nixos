{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    gh
    lazygit
    lazydocker
    k9s
    asdf
    github-copilot-cli
    copilot-language-server
    aichat
    mods
    ripgrep
    fd
    cmake
    sqlite
    sqlcl
    oracle-instantclient
    scrcpy
    android-tools
    android-studio
    vscode
    dbeaver-bin
    typst
  ];
}
