{ ... }:

{
  extraConfigLua = ''
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
                  vim.notify("CS Hub term saved: " .. term, vim.log.levels.INFO)
                else
                  vim.notify("CS Hub error: " .. (res.stderr or ""), vim.log.levels.ERROR)
                end
              end)
            end)
          end)
        end)
      end)
    end, { desc = "Add CS Hub term" })

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
    end, { desc = "Add CS Hub item" })

    vim.api.nvim_create_user_command("CshubDash", function()
      Snacks.terminal.open(
        { "bash", "-lc", "cshub dash; echo; cshub cal; echo; read -rp '[Press Enter to close]'" },
        { win = { style = "float", border = "rounded", width = 0.78, height = 0.78 } }
      )
    end, { desc = "Open CS Hub Dashboard & Calendar" })
  '';
}
