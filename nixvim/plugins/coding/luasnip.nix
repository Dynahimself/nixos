{ hmPkgs, ... }:

{
  plugins = {
    luasnip = {
      enable = true;
      fromVscode = [ { } ];
    };
  };

  extraPlugins = [ hmPkgs.vimPlugins.friendly-snippets ];
}
