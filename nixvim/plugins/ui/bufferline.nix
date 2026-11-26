{ ... }:

{
  plugins = {
    bufferline = {
      enable = true;
      settings.options = {
        mode = "buffers";
        diagnostics = "nvim_lsp";
        always_show_bufferline = false;
        show_buffer_close_icons = false;
        show_close_icon = false;
        separator_style = "thin";
        diagnostics_indicator.__raw = ''
          function(_, _, diag)
            local icons = { error = " ", warning = " ", info = " " }
            local ret = (diag.error and icons.error .. diag.error .. " " or "")
              .. (diag.warning and icons.warning .. diag.warning or "")
            return vim.trim(ret)
          end
        '';
        offsets = [
          {
            filetype = "snacks_layout_box";
            text = "  󰉋 Explorer";
            highlight = "Directory";
            text_align = "left";
          }
        ];
      };
    };
  };
}
