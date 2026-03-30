return {
  {
    "jmbuhr/otter.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
    },
    opts = {
      buffers = {
        set_filetype = true,
      },
    },
    keys = {
      {
        "<leader>oa",
        function()
          require("otter").activate({ "javascript", "css" }, true, true, nil)
        end,
        desc = "Otter Activate (JS/CSS in HTML)",
      },
    },
  },

  -- ADD THIS ENTIRE BLOCK BELOW --
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = {
      { "tpope/vim-dadbod" },
      { "kristijanhusak/vim-dadbod-completion" },
    },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1

      -- Replace YOUR_USER and YOUR_PASS with your actual Oracle credentials
      vim.g.dbs = {
        { name = "Oracle Class", url = "oracle://YOUR_USER:YOUR_PASS@205.237.244.252:1521/ORCL" },
      }
    end,
  },
}
