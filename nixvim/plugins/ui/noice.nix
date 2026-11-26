{ ... }:

{
  plugins = {
    noice = {
      enable = true;
      settings = {
        lsp = {
          override = {
            "vim.lsp.util.convert_input_to_markdown_lines" = true;
            "vim.lsp.util.stylize_markdown" = true;
          };
          signature.auto_open.enabled = false; # Handled by blink-cmp signature
        };
        presets = {
          bottom_search = true;
          command_palette = true;
          long_message_to_split = true;
          inc_rename = true;
          lsp_doc_border = true;
        };
        routes = [
          {
            filter = {
              event = "msg_show";
              any = [
                { find = "%d+L, %d+B"; }
                { find = "; after #%d+"; }
                { find = "; before #%d+"; }
                { find = "%d+ fewer lines"; }
                { find = "%d+ more lines"; }
              ];
            };
            opts.skip = true;
          }
        ];
      };
    };
  };
}
