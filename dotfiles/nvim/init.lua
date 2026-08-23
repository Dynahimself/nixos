-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
vim.api.nvim_create_autocmd("FileType", {
  pattern = "html",
  callback = function()
    vim.keymap.set("i", "!", function()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local line = vim.api.nvim_get_current_line()

      -- Template for web, it's just a lazy template.
      -- Modified logic: Check if the line is empty/whitespace UP TO the cursor.
      -- If it is, then pressing '!' should trigger the template.
      if line:sub(1, col):match("^%s*$") then
        local template = [[<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Exercice</title>
    <link rel="stylesheet" href="catppuccin.css">
</head>
<body>
    <header>
            <div id="title">
                <img src="./images/catppuccin.png" alt="Logo Catppuccin" id="logo">
        <h1 id="titleSwitch">
                <span id="initialTitle">Exercice</span>
                <span id="hoverTitle"><a href="index.html">Index</a></span>
        </h1>
            </div>
    </header>
    <main>
      <article>
        <section id="exercice">
            
        </section>
      </article>
    </main>

    <footer>

    </footer>
      <script>
          "use strict";
          
      </script>
</body>
</html>]]
        vim.snippet.expand(template)
      else
        -- If there is text on the line, just act like a normal '!'
        vim.api.nvim_feedkeys("!", "n", false)
      end
    end, { buffer = true, desc = "HTML template" })
  end,
})

-- :Crun for K&R and CS:APP exercises
-- Bad practices if you're actually writing a project, just for single files.
vim.api.nvim_create_user_command("Crun", function()
  local src = vim.fn.expand("%:p") -- /path/to/file.c
  local bin = vim.fn.expand("%:p:r") -- /path/to/file (no extension)

  -- Save first (I kept forgetting while doing exercises lmao)
  vim.cmd("write")

  -- Vertical split terminal: compile then run
  vim.cmd("vsplit")
  vim.cmd.terminal(
    string.format(
      "gcc -Wall -Wextra -std=c99 -o %s %s && %s",
      vim.fn.shellescape(bin),
      vim.fn.shellescape(src),
      vim.fn.shellescape(bin)
    )
  )

  -- Drop into terminal mode immediately (hit <C-\><C-n> to exit)
  vim.cmd("startinsert")
end, { desc = "Compile & run C (gcc)" })

-- Csrun command
-- If you copy this you need the SDK and something to make
-- .cs files run without a project (like dotnet-script or something)
vim.api.nvim_create_user_command("Csrun", function()
  local file = vim.fn.expand("%:p")
  vim.cmd("terminal dotnet run " .. vim.fn.shellescape(file))
end, {})

--Terminal mode auto-insert
vim.api.nvim_create_autocmd("TermOpen", {
  pattern = "*",
  command = "startinsert",
})

-- SQL formatter configuration for conform.nvim
-- This forces sql-formatter with the Oracle dialect
require("conform").setup({
  formatters_by_ft = {
    sql = { "sql_formatter" },
  },
  formatters = {
    sql_formatter = {
      -- "-l oracle" tells the formatter to use Oracle's specific syntax
      args = { "-l", "plsql" },
    },
  },
})
