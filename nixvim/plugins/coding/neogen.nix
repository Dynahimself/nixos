{ ... }:

{
  plugins = {
    neogen = {
      enable = true;
      settings = {
        snippet_engine = "luasnip";
        languages.cs.template.annotation_convention = "xmldoc";
      };
    };
  };
}
