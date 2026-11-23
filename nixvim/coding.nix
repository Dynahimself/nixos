{ pkgs }:
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

    luasnip = {
      enable = true;
      fromVscode = [ { } ];
    };

    treesitter = {
      enable = true;
      settings = {
        highlight.enable = true;
        indent.enable = true;
      };
    };

    treesitter-textobjects = {
      enable = true;
      settings = {
        select = {
          enable = true;
          lookahead = true;
          keymaps = {
            "af" = "@function.outer";
            "lf" = "@function.inner";
            "ac" = "@class.outer";
            "lc" = "@class.inner";
            "aa" = "@parameter.outer";
            "la" = "@parameter.inner";
            "ab" = "@block.outer";
            "lb" = "@block.inner";
          };
        };
        move = {
          enable = true;
          set_jumps = true;
          goto_next_start = {
            "]f" = "@function.outer";
            "]c" = "@class.outer";
            "]a" = "@parameter.inner";
          };
          goto_previous_start = {
            "[f" = "@function.outer";
            "[c" = "@class.outer";
            "[a" = "@parameter.inner";
          };
        };
      };
    };

    ts-autotag.enable = true;

    mini = {
      enable = true;
      modules = {
        ai = {
          n_lines = 500;
          mappings = {
            around = "a";
            inside = "l";
            around_next = "an";
            inside_next = "ln";
            around_last = "ap";
            inside_last = "lp";
          };
        };
        surround = {
          mappings = {
            add = "gsa";
            delete = "gsd";
            find = "gsf";
            find_left = "gsF";
            highlight = "gsh";
            replace = "gsr";
            update_n_lines = "gsn";
          };
        };
        pairs = { };
        icons = { };
        hipatterns = { };
      };
    };

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

    harpoon = {
      enable = true;
      settings.settings = {
        save_on_toggle = true;
        sync_on_ui_close = true;
      };
    };

    glance = {
      enable = true;
      settings = {
        border = { enable = true; top_char = "─"; bottom_char = "─"; };
        theme.enable = true;
        mappings = {
          list = {
            e = "next";
            i = "previous";
            o = "jump";
            "<CR>" = "jump";
            q = "close";
            "<Esc>" = "close";
          };
          preview = {
            q = "close";
            "<Esc>" = "close";
          };
        };
      };
    };

    yanky = {
      enable = true;
      settings = {
        highlight = { on_put = true; on_yank = false; timer = 180; };
        preserve_cursor_position.enabled = true;
      };
    };

    dial.enable = true;

    treesj = {
      enable = true;
      settings = {
        use_default_keymaps = false;
        max_join_length = 140;
      };
    };

    neogen = {
      enable = true;
      settings = {
        snippet_engine = "luasnip";
        languages.cs.template.annotation_convention = "xmldoc";
      };
    };

    refactoring.enable = true;
    undotree = {
      enable = true;
      settings = {
        FocusWhenToggle = true;
        WindowLayout = 2;
      };
    };

    flash = {
      enable = true;
      settings.labels = "arstgmneioqwfpbjluyzxcdvkh";
    };

    trouble = {
      enable = true;
      settings.keys = {
        e = "next";
        i = "prev";
        o = "jump";
        n = "fold_close";
      };
    };

    aerial = {
      enable = true;
      settings.keymaps = {
        e = "actions.down_and_scroll";
        i = "actions.up_and_scroll";
        o = "actions.jump";
        n = "actions.tree_close";
      };
    };

    grug-far.enable = true;
    todo-comments.enable = true;
    persistence.enable = true;
    render-markdown.enable = true;

    leetcode = {
      enable = true;
      settings = {
        lang = "csharp";
        storage.home = "~/projects/leetcode";
      };
    };
  };

  extraConfigLua = ''
    -- Alias mini.icons as nvim-web-devicons
    pcall(function() require("mini.icons").mock_nvim_web_devicons() end)

    pcall(function()
      local augend = require("dial.augend")
      require("dial.config").augends:register_group({
        default = {
          augend.integer.alias.decimal_int,
          augend.integer.alias.hex,
          augend.date.alias["%Y-%m-%d"],
          augend.constant.alias.bool,
          augend.semver.alias.semver,
          augend.constant.new({ elements = { "and", "or" }, word = true, cyclic = true }),
          augend.constant.new({ elements = { "&&", "||" }, word = false, cyclic = true }),
          augend.constant.new({ elements = { "==", "!=" }, word = false, cyclic = true }),
          augend.constant.new({ elements = { "public", "private", "protected", "internal" }, word = true, cyclic = true }),
          augend.constant.new({ elements = { "const", "let", "var" }, word = true, cyclic = true }),
          augend.constant.new({ elements = { "true", "false" }, word = true, cyclic = true }),
          augend.constant.new({ elements = { "True", "False" }, word = true, cyclic = true }),
          augend.constant.new({ elements = { "enable", "disable" }, word = true, cyclic = true }),
        },
      })
    end)

    -- Hardtime
    pcall(function()
      require("hardtime").setup({
        disabled_filetypes = {
          "qf", "help", "Trouble", "trouble", "aerial", "grug-far", "oil", "harpoon",
          "DiffviewFiles", "DiffviewFileHistory", "OverseerList", "undotree", "diff",
          "neotest-summary", "neotest-output", "neotest-output-panel", "Glance",
          "snacks_dashboard", "snacks_picker_list", "snacks_picker_input",
          "snacks_terminal", "dapui_scopes", "dapui_breakpoints",
          "dapui_stacks", "dapui_watches", "dap-repl", "dbui", "dbout",
        },
        restricted_keys = {
          ["n"] = { "n", "x" },
          ["e"] = { "n", "x" },
          ["i"] = { "n", "x" },
          ["o"] = { "n", "x" },
          ["+"] = { "n", "x" },
          ["gj"] = { "n", "x" },
          ["gk"] = { "n", "x" },
          ["h"] = {}, ["j"] = {}, ["k"] = {}, ["l"] = {},
        },
        disabled_keys = {
          ["<Up>"] = { "", "i" }, ["<Down>"] = { "", "i" },
          ["<Left>"] = { "", "i" }, ["<Right>"] = { "", "i" },
        },
        hints = {
          ["%^l"] = { message = function() return "Use L instead of ^l" end, length = 2 },
          ["[^fFtT]ol"] = { message = function() return "Use a instead of ol" end, length = 3 },
          ["%$a"] = { message = function() return "Use A instead of $a" end, length = 2 },
          ["d%$"] = { message = function() return "Use D instead of d$" end, length = 2 },
          ["y%$"] = { message = function() return "Use Y instead of y$" end, length = 2 },
          ["c%$"] = { message = function() return "Use C instead of c$" end, length = 2 },
          ["D[aA]"] = { message = function(k) return "Use C instead of D" .. k:sub(2) end, length = 2 },
        },
      })
    end)
  '';
}
