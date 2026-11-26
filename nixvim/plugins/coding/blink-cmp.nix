{ ... }:

{
  plugins = {
    blink-cmp = {
      enable = true;
      settings = {
        snippets.preset = "luasnip";
        appearance = {
          use_nvim_cmp_as_default = false;
          nerd_font_variant = "mono";
        };
        completion = {
          menu = {
            border = "rounded";
            draw = {
              treesitter = [ "lsp" ];
              columns.__raw = ''{ { "kind_icon" }, { "label", "label_description", gap = 1 }, { "kind" } }'';
            };
          };
          documentation = {
            auto_show = true;
            auto_show_delay_ms = 200;
            window.border = "rounded";
          };
          ghost_text.enabled = true;
        };
        signature = {
          enabled = true;
          window.border = "rounded";
        };
        sources = {
          default = [ "lsp" "path" "snippets" "buffer" ];
          per_filetype = {
            sql = [ "dadbod" "snippets" "buffer" ];
            mysql = [ "dadbod" "snippets" "buffer" ];
            plsql = [ "dadbod" "snippets" "buffer" ];
            lua = [ "lazydev" "lsp" "path" "snippets" "buffer" ];
          };
          providers = {
            dadbod = {
              name = "Dadbod";
              module = "vim_dadbod_completion.blink";
              score_offset = 85;
            };
            lazydev = {
              name = "LazyDev";
              module = "lazydev.integrations.blink";
              score_offset = 100;
            };
          };
        };
        keymap = {
          preset = "default";
          "<C-e>" = [ "select_next" "fallback" ];
          "<C-i>" = [ "select_prev" "fallback" ];
          "<Tab>" = [ "select_and_accept" "snippet_forward" "fallback" ];
          "<S-Tab>" = [ "select_prev" "snippet_backward" "fallback" ];
          "<CR>" = [ "accept" "fallback" ];
        };
      };
    };
  };
}
