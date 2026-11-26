{ ... }:

{
  programs.yazi = {
    enable = true;
    enableZshIntegration = true;
    shellWrapperName = "y";
    keymap.mgr.prepend_keymap = [
      { on = "n"; run = "leave"; desc = "Go back to parent directory"; }
      { on = "e"; run = "arrow 1"; desc = "Move cursor down"; }
      { on = "i"; run = "arrow -1"; desc = "Move cursor up"; }
      { on = "o"; run = "enter"; desc = "Enter child directory"; }
      { on = "k"; run = "find_arrow"; desc = "Next found"; }
      { on = "K"; run = "find_arrow --previous"; desc = "Previous found"; }
    ];
  };
}
