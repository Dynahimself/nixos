{ ... }:

{
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f --hidden --follow --exclude .git";
    defaultOptions = [
      "--height=55%"
      "--layout=reverse"
      "--border=rounded"
      "--info=inline"
      "--bind=ctrl-e:down,ctrl-i:up"
    ];
    historyWidget.command = ""; # Keep Atuin on Ctrl-R
    fileWidget = {
      command = "fd --type f --hidden --follow --exclude .git";
      options = [ "--preview='bat --color=always --style=numbers --line-range=:200 {}'" ];
    };
    changeDirWidget = {
      command = "fd --type d --hidden --follow --exclude .git";
      options = [ "--preview='eza --tree --level=2 --icons --color=always {}'" ];
    };
  };
}
