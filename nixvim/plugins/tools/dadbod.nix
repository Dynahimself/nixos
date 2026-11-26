{ hmPkgs, ... }:

{
  extraPlugins = with hmPkgs.vimPlugins; [
    vim-dadbod
    vim-dadbod-ui
    vim-dadbod-completion
  ];

  extraConfigLua = ''
    -- dadbod-ui connections
    vim.g.db_ui_use_nerd_fonts = 1
    vim.g.db_ui_show_database_icon = 1
    vim.g.dbs = {
      {
        name = "Oracle Class",
        url = "oracle://C##FOURNIEO:Lycia@205.237.244.252:1521/ORCL",
      },
    }
  '';
}
