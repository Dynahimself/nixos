{ ... }:

{
  extraConfigLua = ''
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
            vim.notify("CSdebug: build failed (see quickfix)", vim.log.levels.ERROR)
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
  '';
}
