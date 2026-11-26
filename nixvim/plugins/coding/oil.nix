{ ... }:

{
  plugins = {
    oil = {
      enable = true;
      settings = {
        default_file_explorer = false; # Keep Snacks on <leader>e; Oil on -
        delete_to_trash = true;
        skip_confirm_for_simple_edits = true;
        win_options.signcolumn = "yes:2";
        view_options.show_hidden = true;
        float = {
          padding = 3;
          max_width = 100;
          max_height = 36;
          border = "rounded";
        };
        use_default_keymaps = false;
        keymaps = {
          "g?" = "actions.show_help";
          "<CR>" = "actions.select";
          "o" = "actions.select";
          "n" = "actions.parent";
          "-" = "actions.parent";
          "_" = "actions.open_cwd";
          "<C-s>" = { __unkeyed-1 = "actions.select"; opts.horizontal = true; };
          "<C-v>" = { __unkeyed-1 = "actions.select"; opts.vertical = true; };
          "<C-p>" = "actions.preview";
          "q" = "actions.close";
          "<Esc>" = "actions.close";
          "gr" = "actions.refresh";
          "g." = "actions.toggle_hidden";
        };
      };
    };

    oil-git-status.enable = true;
  };
}
