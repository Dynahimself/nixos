{ ... }:

{
  plugins = {
    overseer = {
      enable = true;
      settings.task_list = {
        direction = "bottom";
        min_height = 10;
        max_height = 18;
        bindings = {
          e = "NextTask";
          i = "PrevTask";
          o = "Open";
          q = "Close";
        };
      };
    };
  };
}
