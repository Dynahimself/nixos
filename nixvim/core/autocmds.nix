{ ... }:

{
  autoCmd = [
    {
      event = [ "TermOpen" ];
      pattern = [ "*" ];
      command = "startinsert";
    }
    {
      event = [ "TextYankPost" ];
      pattern = [ "*" ];
      callback.__raw = "function() vim.hl.on_yank({ timeout = 160 }) end";
    }
    # Equalize splits on resize
    {
      event = [ "VimResized" ];
      pattern = [ "*" ];
      callback.__raw = "function() local cur = vim.fn.tabpagenr(); vim.cmd('tabdo wincmd ='); vim.cmd('tabnext ' .. cur) end";
    }
    # Restore cursor position
    {
      event = [ "BufReadPost" ];
      pattern = [ "*" ];
      callback.__raw = ''
        function(ev)
          local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
          local lcount = vim.api.nvim_buf_line_count(ev.buf)
          if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
          end
        end
      '';
    }
    # Close help/qf panels with q
    {
      event = [ "FileType" ];
      pattern = [ "help" "qf" "man" "lspinfo" "checkhealth" "notify" "neotest-output" "neotest-output-panel" "neotest-summary" ];
      callback.__raw = ''
        function(ev)
          vim.bo[ev.buf].buflisted = false
          vim.keymap.set("n", "q", "<cmd>close<cr>", { buffer = ev.buf, silent = true, desc = "Close Panel" })
        end
      '';
    }
  ];

  extraConfigLua = ''
    -- Fold text with line count
    function _G.DynaFoldText()
      local line = vim.fn.getline(vim.v.foldstart)
      local count = vim.v.foldend - vim.v.foldstart + 1
      return line .. string.format("   󰁂 %d lines ", count)
    end
  '';
}
