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
}
