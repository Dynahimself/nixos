{ hmPkgs, ... }:

{
  plugins = {
    lint = {
      enable = true;
      lintersByFt = {
        javascript = [ "eslint" ];
        typescript = [ "eslint" ];
        javascriptreact = [ "eslint" ];
        typescriptreact = [ "eslint" ];
      };
    };
  };

  extraPackages = [ hmPkgs.eslint ];
}
