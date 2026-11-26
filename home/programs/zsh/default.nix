{ ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      # Run fastfetch in top-level interactive shells only
      if [[ -o interactive ]] && [[ -z "''${NVIM:-}" ]] && [[ "''${SHLVL:-1}" -le 2 ]] && [[ -t 1 ]]; then
        fastfetch
      fi
      export PATH="$HOME/.local/bin:$PATH"

      # cd to Windows user directory
      win() {
        cd /mnt/c/Users/$(cmd.exe /c "echo %USERNAME%" 2>/dev/null | tr -d '\r') 2>/dev/null \
          || cd /mnt/c/Users/*/ 2>/dev/null \
          || echo "Not in WSL or Windows drive not mounted"
      }

      # cd to latest TP directory
      tp() {
        local latest
        latest=$(ls -1dt "$HOME/cswip/Aoop/homeworks"/TP* "$HOME/neoCS"/*/TP* "$HOME/neoCS"/TP* 2>/dev/null | head -n1)
        if [[ -n "$latest" ]]; then
          cd "$latest" && pwd
        else
          cd "$HOME/cswip/Aoop" 2>/dev/null || cd "$HOME/neoCS" 2>/dev/null || echo "Homework dir not found"
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
      ld = "lazydocker";
      npush = "nas-cache-push";
      nr = "nh os switch /etc/nixos";
      nrd = "nh os switch --dry /etc/nixos";
      nru = "nh os switch --update /etc/nixos";
      hreload = "hyprctl reload";
      csh = "cshub";
      csa = "cshub agenda";
      csc = "cshub cal";
      csd = "cshub dash";
    };
  };
}
