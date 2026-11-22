{ pkgs }:
{
  extraConfigLua = ''
    -- Custom native Neovim 0.12 fold text with line count badge
    function _G.DynaFoldText()
      local line = vim.fn.getline(vim.v.foldstart)
      local count = vim.v.foldend - vim.v.foldstart + 1
      return line .. string.format("   󰁂 %d lines ", count)
    end

    -- :Crun — Compile & run single-file C99 (K&R / CS:APP) in Snacks floating terminal
    vim.api.nvim_create_user_command("Crun", function()
      local src = vim.fn.expand("%:p")
      local bin = vim.fn.expand("%:p:r")
      vim.cmd("write")
      local cmd = string.format(
        "gcc -Wall -Wextra -std=c99 -g -o %s %s && %s; echo; read -rp '[Press Enter to close]'",
        vim.fn.shellescape(bin), vim.fn.shellescape(src), vim.fn.shellescape(bin)
      )
      Snacks.terminal.open({ "bash", "-lc", cmd }, { win = { style = "float", border = "rounded", width = 0.8, height = 0.7 } })
    end, { desc = "Compile & run C99 (gcc)" })

    -- :Csrun — Run .NET 10 project or single file in floating terminal
    vim.api.nvim_create_user_command("Csrun", function()
      local file = vim.fn.expand("%:p")
      vim.cmd("write")
      local srcdir = vim.fn.fnamemodify(file, ":h")
      local proj = vim.fs.find(function(n) return n:match("%.csproj$") end, { upward = true, path = srcdir })[1]
      local cmd = proj
        and ("dotnet run --project " .. vim.fn.shellescape(proj))
        or ("dotnet run " .. vim.fn.shellescape(file))
      Snacks.terminal.open(
        { "bash", "-lc", cmd .. "; echo; read -rp '[Press Enter to close]'" },
        { win = { style = "float", border = "rounded", width = 0.82, height = 0.72 } }
      )
    end, { desc = "Run .NET project or file" })

    -- :Cstest — Run dotnet test in floating terminal
    vim.api.nvim_create_user_command("Cstest", function()
      vim.cmd("write")
      local srcdir = vim.fn.expand("%:p:h")
      local sln = vim.fs.find(function(n) return n:match("%.slnx?$") or n:match("%.csproj$") end, { upward = true, path = srcdir })[1]
      local target = sln and vim.fn.shellescape(sln) or ""
      Snacks.terminal.open(
        { "bash", "-lc", "dotnet test " .. target .. " --nologo; echo; read -rp '[Press Enter to close]'" },
        { win = { style = "float", border = "rounded", width = 0.85, height = 0.75 } }
      )
    end, { desc = "Run dotnet test" })

    -- :CSdebug — Async-clean build & launch netcoredbg (populates Quickfix on build failure)
    vim.api.nvim_create_user_command("CSdebug", function()
      local file = vim.fn.expand("%:p")
      if file == "" then
        return vim.notify("CSdebug: no file in buffer", vim.log.levels.WARN)
      end
      vim.cmd("write")

      local srcdir = vim.fn.fnamemodify(file, ":h")
      local proj = vim.fs.find(function(name) return name:match("%.csproj$") end, { upward = true, path = srcdir })[1]
      local sln = proj and nil
        or vim.fs.find(function(name) return name:match("%.slnx?$") end, { upward = true, path = srcdir })[1]

      local target, cwd, name
      if proj then
        target, cwd, name = proj, vim.fn.fnamemodify(proj, ":h"), vim.fn.fnamemodify(proj, ":t:r")
      elseif sln then
        target, cwd, name = sln, vim.fn.fnamemodify(sln, ":h"), vim.fn.fnamemodify(sln, ":t:r")
      else
        name = vim.fn.fnamemodify(file, ":t:r")
        local tmp = vim.fn.stdpath("cache") .. "/csdebug/" .. name
        vim.fn.mkdir(tmp, "p")
        local includes = {}
        for _, n in ipairs(vim.fn.glob(srcdir .. "/*.cs", false, true)) do
          local base = vim.fn.fnamemodify(n, ":t")
          table.insert(includes, '    <Compile Include="' .. n .. '" Link="' .. base .. '" />')
        end
        vim.fn.writefile({
          '<Project Sdk="Microsoft.NET.Sdk">',
          '  <PropertyGroup>',
          '    <OutputType>Exe</OutputType>',
          '    <TargetFramework>net10.0</TargetFramework>',
          '    <ImplicitUsings>enable</ImplicitUsings>',
          '    <Nullable>enable</Nullable>',
          '    <AssemblyName>' .. name .. '</AssemblyName>',
          '  </PropertyGroup>',
          '  <ItemGroup>',
          table.concat(includes, "\n"),
          '  </ItemGroup>',
          '</Project>',
        }, tmp .. "/" .. name .. ".csproj")
        target, cwd = tmp .. "/" .. name .. ".csproj", srcdir
      end

      vim.notify("CSdebug: building " .. vim.fn.fnamemodify(target, ":t") .. "…")
      vim.system({ "dotnet", "build", target, "--nologo", "-v", "q" }, { text = true }, function(res)
        vim.schedule(function()
          local out = (res.stdout or "") .. "\n" .. (res.stderr or "")
          if res.code ~= 0 then
            vim.notify("CSdebug: build FAILED — check Quickfix", vim.log.levels.ERROR)
            vim.fn.setqflist({}, " ", { title = "CSdebug Build Errors", lines = vim.split(out, "\n") })
            vim.cmd("Trouble qflist open")
            return
          end

          local dll = nil
          for line in out:gmatch("[^\r\n]+") do
            local m = line:match("%->%s*(%S+%.dll)")
            if m then dll = m end
          end
          if not dll or vim.fn.filereadable(dll) == 0 then
            local hits = vim.fn.glob(vim.fn.fnamemodify(target, ":h") .. "/bin/Debug/**/" .. name .. ".dll", false, true)
            dll = hits[1]
          end
          if not dll then
            return vim.notify("CSdebug: no DLL found after build", vim.log.levels.ERROR)
          end

          vim.notify("CSdebug: debugging " .. vim.fn.fnamemodify(dll, ":t"))
          require("dap").run({
            type = "coreclr",
            request = "launch",
            name = "CSdebug " .. vim.fn.fnamemodify(dll, ":t:r"),
            program = dll,
            cwd = cwd,
          })
        end)
      end)
    end, { desc = "Async build & debug .NET (project or loose file)" })

    -- :SmartPreview — Dispatches TypstPreviewToggle or MarkdownPreviewToggle by filetype
    vim.api.nvim_create_user_command("SmartPreview", function()
      local ft = vim.bo.filetype
      if ft == "typst" then
        vim.cmd("TypstPreviewToggle")
      elseif ft == "markdown" then
        vim.cmd("MarkdownPreviewToggle")
      else
        vim.notify("SmartPreview: open a Markdown or Typst file", vim.log.levels.INFO)
      end
    end, { desc = "Smart live preview for Markdown/Typst" })

    -- :CshubTerm — Offline-first term capture via cshub CLI (merges with Pi over Tailscale)
    vim.api.nvim_create_user_command("CshubTerm", function()
      local default_term = vim.fn.expand("<cword>")
      vim.ui.input({ prompt = "󰑴 CS Hub Term: ", default = default_term }, function(term)
        if not term or vim.trim(term) == "" then return end
        vim.ui.input({ prompt = "Definition (" .. term .. "): " }, function(def)
          if not def or vim.trim(def) == "" then return end
          vim.ui.input({ prompt = "Course (opt, e.g. Aoop / SQL): " }, function(course)
            local cmd = { "cshub", "term", "add", term, def, "-s", "Neovim (" .. vim.fn.expand("%:t") .. ")" }
            if course and vim.trim(course) ~= "" then
              table.insert(cmd, "-c"); table.insert(cmd, vim.trim(course))
            end
            vim.system(cmd, { text = true }, function(res)
              vim.schedule(function()
                if res.code == 0 then
                  vim.notify("CS Hub Term saved (synced/queued): " .. term, vim.log.levels.INFO)
                else
                  vim.notify("CS Hub error: " .. (res.stderr or ""), vim.log.levels.ERROR)
                end
              end)
            end)
          end)
        end)
      end)
    end, { desc = "Capture flashcard term (offline-first CS Hub)" })

    -- :CshubAdd — Quick-add exam/homework/task from Neovim (offline-first)
    vim.api.nvim_create_user_command("CshubAdd", function()
      vim.ui.select({ "exam", "homework", "deadline", "task" }, { prompt = "CS Hub Kind:" }, function(kind)
        if not kind then return end
        vim.ui.input({ prompt = "Title: " }, function(title)
          if not title or vim.trim(title) == "" then return end
          vim.ui.input({ prompt = "Date (today, tmr, +3d, fri, 12-04): " }, function(dt_in)
            vim.ui.input({ prompt = "Course (opt): " }, function(course)
              local cmd = (kind == "task") and { "cshub", "todo", title } or { "cshub", kind, title, dt_in or "today" }
              if kind == "task" and dt_in and vim.trim(dt_in) ~= "" then
                table.insert(cmd, "-d"); table.insert(cmd, vim.trim(dt_in))
              end
              if course and vim.trim(course) ~= "" then
                table.insert(cmd, "-c"); table.insert(cmd, vim.trim(course))
              end
              vim.system(cmd, { text = true }, function(res)
                vim.schedule(function()
                  if res.code == 0 then
                    vim.notify("CS Hub added " .. kind .. ": " .. title, vim.log.levels.INFO)
                  else
                    vim.notify("CS Hub error: " .. (res.stderr or ""), vim.log.levels.ERROR)
                  end
                end)
              end)
            end)
          end)
        end)
      end)
    end, { desc = "Add exam/homework/task to CS Hub (offline-first)" })

    -- :CshubDash — Open CS Hub terminal dashboard in Snacks float
    vim.api.nvim_create_user_command("CshubDash", function()
      Snacks.terminal.open(
        { "bash", "-lc", "cshub dash; echo; cshub cal; echo; read -rp '[Press Enter to close]'" },
        { win = { style = "float", border = "rounded", width = 0.78, height = 0.78 } }
      )
    end, { desc = "Open CS Hub Dashboard & Calendar" })

    -- HTML '!' CEGEP template (triggers only at empty line start)
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

    -- Discord Rich Presence (guarded so SSH/WSL/no-Discord never errors)
    pcall(function()
      require("presence").setup({
        auto_update = true,
        neovim_image_text = "The One True Text Editor",
        main_image = "neovim",
        client_id = "793271441293967371",
        debounce_timeout = 10,
        buttons = true,
        show_time = true,
      })
    end)

    -- vim-dadbod-ui connections
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
