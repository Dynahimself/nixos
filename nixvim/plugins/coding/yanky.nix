{ ... }:

{
  plugins = {
    yanky = {
      enable = true;
      settings = {
        highlight = { on_put = true; on_yank = false; timer = 180; };
        preserve_cursor_position.enabled = true;
      };
    };
  };
}
