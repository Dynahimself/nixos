{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      if [[ -o interactive ]] && [[ -z "''${NVIM:-}" ]] && [[ "''${SHLVL:-1}" -le 2 ]] && [[ -t 1 ]]; then
        fastfetch
      fi
      export PATH="$HOME/.local/bin:$PATH"

      # cd to Windows user directory
      win() {
        cd /mnt/c/Users/$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r') 2>/dev/null \
          || cd /mnt/c/Users/Olivi 2>/dev/null \
          || echo "Windows drive not mounted"
      }

      # cd to latest TP directory
      tp() {
        local latest
        latest=$(ls -1dt "$HOME/cswipp"/TP* "$HOME/cswip/Aoop/homeworks"/TP* /mnt/c/Users/Olivi/cswip/TP* 2>/dev/null | head -n1)
        if [[ -n "$latest" ]]; then
          cd "$latest" && pwd
        else
          cd "$HOME/cswipp" 2>/dev/null || cd /mnt/c/Users/Olivi/cswip 2>/dev/null || echo "Homework dir not found"
        fi
      }
    '';
    shellAliases = {
      ls = "eza --icons --group-directories-first";
      ll = "eza -la --icons --git --group-directories-first";
      lt = "eza --tree --level=2 --icons";
      cat = "bat --style=plain";
      v = "nvim";
      lg = "lazygit";
      csh = "cshub";
      csa = "cshub agenda";
      csc = "cshub cal";
      csd = "cshub dash";
      # Pin #wsl flake target
      rebuild = "sudo nixos-rebuild switch --flake /etc/nixos#wsl";
      nr = "nh os switch /etc/nixos -H wsl";
    };
  };
}
