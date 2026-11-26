{ ... }:

{
  plugins = {
    diffview = {
      enable = true;
      settings = {
        enhanced_diff_hl = true;
        view.merge_tool.layout = "diff3_mixed";
        keymaps = {
          file_panel = [
            { mode = "n"; key = "e"; action.__raw = "require('diffview.actions').next_entry"; description = "Next Entry"; }
            { mode = "n"; key = "i"; action.__raw = "require('diffview.actions').prev_entry"; description = "Prev Entry"; }
            { mode = "n"; key = "o"; action.__raw = "require('diffview.actions').select_entry"; description = "Open Diff"; }
          ];
          file_history_panel = [
            { mode = "n"; key = "e"; action.__raw = "require('diffview.actions').next_entry"; description = "Next Entry"; }
            { mode = "n"; key = "i"; action.__raw = "require('diffview.actions').prev_entry"; description = "Prev Entry"; }
            { mode = "n"; key = "o"; action.__raw = "require('diffview.actions').select_entry"; description = "Open Commit"; }
          ];
        };
      };
    };
  };
}
