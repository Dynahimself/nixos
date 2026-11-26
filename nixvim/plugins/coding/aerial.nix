{ ... }:

{
  plugins = {
    aerial = {
      enable = true;
      settings.keymaps = {
        e = "actions.down_and_scroll";
        i = "actions.up_and_scroll";
        o = "actions.jump";
        n = "actions.tree_close";
      };
    };
  };
}
