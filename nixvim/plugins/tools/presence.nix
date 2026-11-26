{ hmPkgs, ... }:

{
  extraPlugins = [ hmPkgs.vimPlugins.presence-nvim ];

  extraConfigLua = ''
    -- Guarded Discord Rich Presence
    pcall(function()
      require("presence").setup({
        auto_update = true,
        neovim_image_text = "Neovim",
        main_image = "neovim",
        client_id = "793271441293967371",
        debounce_timeout = 10,
        buttons = true,
        show_time = true,
      })
    end)
  '';
}
