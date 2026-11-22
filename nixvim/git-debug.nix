{ pkgs }:
{
  plugins = {
    # Gitsigns with Colemak-DH hunk workflow
    gitsigns = {
      enable = true;
      settings = {
        signs = {
          add.text = "▎";
          change.text = "▎";
          delete.text = "";
          topdelete.text = "";
          changedelete.text = "▎";
          untracked.text = "▎";
        };
        current_line_blame_opts = {
          delay = 350;
          virt_text_pos = "eol";
        };
        on_attach.__raw = ''
          function(buffer)
            local gs = package.loaded.gitsigns
            local function map(mode, lhs, rhs, desc)
              vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc })
            end
            map("n", "]h", function() if vim.wo.diff then vim.cmd.normal({ "]c", bang = true }) else gs.nav_hunk("next") end end, "Next Git Hunk")
            map("n", "[h", function() if vim.wo.diff then vim.cmd.normal({ "[c", bang = true }) else gs.nav_hunk("prev") end end, "Prev Git Hunk")
            map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
            map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
            map("n", "<leader>ghS", gs.stage_buffer, "Stage Buffer")
            map("n", "<leader>ghu", gs.undo_stage_hunk, "Undo Stage Hunk")
            map("n", "<leader>ghp", gs.preview_hunk_inline, "Preview Hunk Inline")
            map("n", "<leader>ghb", function() gs.blame_line({ full = true }) end, "Blame Line (Full)")
            map("n", "<leader>ghd", gs.diffthis, "Diff This")
            map({ "o", "x" }, "lh", ":<C-U>Gitsigns select_hunk<CR>", "Inner Git Hunk")
            map({ "o", "x" }, "ah", ":<C-U>Gitsigns select_hunk<CR>", "Around Git Hunk")
          end
        '';
      };
    };

    # Diffview (full git diffs, merge conflicts & file history) — Colemak-DH
    diffview = {
      enable = true;
      settings = {
        enhanced_diff_hl = true;
        view.merge_tool.layout = "diff3_mixed";
        keymaps = {
          file_panel = [
            { mode = "n"; key = "e"; action.__raw = "require('diffview.actions').next_entry"; description = "Next Entry"; }
            { mode = "n"; key = "i"; action.__raw = "require('diffview.actions').prev_entry"; description = "Prev Entry"; }
            { mode = "n"; key = "o"; action.__raw = "require('diffview.actions').select_entry"; description = "Open Diff"; }
          ];
          file_history_panel = [
            { mode = "n"; key = "e"; action.__raw = "require('diffview.actions').next_entry"; description = "Next Entry"; }
            { mode = "n"; key = "i"; action.__raw = "require('diffview.actions').prev_entry"; description = "Prev Entry"; }
            { mode = "n"; key = "o"; action.__raw = "require('diffview.actions').select_entry"; description = "Open Commit"; }
          ];
        };
      };
    };

    # Neotest (C#/.NET, Python, Go, Rust)
    neotest = {
      enable = true;
      adapters = {
        dotnet.enable = true;
        python.enable = true;
        go.enable = true;
        rust.enable = true;
      };
      settings = {
        output.open_on_run = false;
        summary.mappings = {
          expand = [ "<CR>" "o" ];
          jumpto = "O";
          next_failed = "]t";
          prev_failed = "[t";
        };
      };
    };

    # Overseer async task runner (dotnet, gcc, nix, cargo)
    overseer = {
      enable = true;
      settings.task_list = {
        direction = "bottom";
        min_height = 10;
        max_height = 18;
        bindings = {
          e = "NextTask";
          i = "PrevTask";
          o = "Open";
          q = "Close";
        };
      };
    };

    # DAP (.NET 10 netcoredbg + Go delve) + auto-opening DAP-UI
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
          command = "${pkgs.netcoredbg}/bin/netcoredbg";
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
    -- Auto-open/close DAP UI cleanly on debug sessions
    pcall(function()
      local dap, dapui = require("dap"), require("dapui")
      dap.listeners.after.event_initialized["dyna_dapui"] = function() dapui.open() end
      dap.listeners.before.event_terminated["dyna_dapui"] = function() dapui.close() end
      dap.listeners.before.event_exited["dyna_dapui"] = function() dapui.close() end
    end)
  '';
}
