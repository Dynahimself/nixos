{ hmPkgs, ... }:

{
  plugins = {
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
  };

  extraPlugins = [ hmPkgs.vimPlugins.ts-comments-nvim ];
}
