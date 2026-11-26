{ ... }:

{
  plugins = {
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
  };
}
