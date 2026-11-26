{ hmPkgs, ... }:

{
  extraPlugins = with hmPkgs.vimPlugins; [
    hardtime-nvim
    nui-nvim
  ];

  extraConfigLua = ''
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
