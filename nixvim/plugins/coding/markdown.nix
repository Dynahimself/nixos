{ hmPkgs, ... }:

{
  plugins.render-markdown.enable = true;

  extraPlugins = [ hmPkgs.vimPlugins.markdown-preview-nvim ];
}
