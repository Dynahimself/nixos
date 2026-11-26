{ ... }:

{
  extraConfigLua = ''
    -- HTML '!' template (empty line start only)
    vim.api.nvim_create_autocmd("FileType", {
      pattern = "html",
      callback = function()
        vim.keymap.set("i", "!", function()
          local col = vim.api.nvim_win_get_cursor(0)[2]
          local line = vim.api.nvim_get_current_line()
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
    <footer></footer>
    <script>
        "use strict";

    </script>
</body>
</html>]]
            vim.snippet.expand(template)
          else
            vim.api.nvim_feedkeys("!", "n", false)
          end
        end, { buffer = true, desc = "HTML template" })
      end,
    })
  '';
}
