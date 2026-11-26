{ ... }:

{
  extraConfigLua = ''
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
  '';
}
