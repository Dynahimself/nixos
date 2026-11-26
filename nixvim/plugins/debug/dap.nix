{ hmPkgs, ... }:

{
  plugins = {
    dap = {
      enable = true;
      signs = {
        dapBreakpoint = { text = ""; texthl = "DiagnosticError"; };
        dapBreakpointCondition = { text = ""; texthl = "DiagnosticWarn"; };
        dapBreakpointRejected = { text = ""; texthl = "DiagnosticError"; };
        dapLogPoint = { text = ".>"; texthl = "DiagnosticInfo"; };
        dapStopped = { text = "󰁕"; texthl = "DiagnosticWarn"; linehl = "Visual"; };
      };
      adapters.executables = {
        coreclr = {
          command = "${hmPkgs.netcoredbg}/bin/netcoredbg";
          args = [ "--interpreter=vscode" ];
        };
      };
      configurations.cs = [
        {
          type = "coreclr";
          request = "launch";
          name = "Launch .NET";
          program.__raw = ''
            function()
              local cwd = vim.fn.getcwd()
              local name = vim.fn.fnamemodify(cwd, ":t")
              local dlls = vim.fn.glob(cwd .. "/bin/Debug/**/*.dll", false, true)
              for _, d in ipairs(dlls) do
                if vim.fn.fnamemodify(d, ":t") == name .. ".dll" then return d end
              end
              if #dlls > 0 then return dlls[1] end
              return vim.fn.input("Path to dll: ", cwd .. "/bin/Debug/", "file")
            end
          '';
        }
      ];
    };
    dap-ui.enable = true;
    dap-virtual-text.enable = true;
  };

  extraConfigLua = ''
    pcall(function()
      local dap, dapui = require("dap"), require("dapui")
      dap.listeners.after.event_initialized["dyna_dapui"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dyna_dapui"] = function() dapui.close() end
      dap.listeners.before.event_exited["dyna_dapui"] = function() dapui.close() end
    end)
  '';
}
