{ ... }:

{
  diagnostic.settings = {
    virtual_text = false; # Handled by tiny-inline-diagnostic
    underline = true;
    update_in_insert = false;
    severity_sort = true;
    float = {
      border = "rounded";
      source = true;
    };
    signs.text.__raw = ''
      {
        [vim.diagnostic.severity.ERROR] = " ",
        [vim.diagnostic.severity.WARN]  = " ",
        [vim.diagnostic.severity.INFO]  = " ",
        [vim.diagnostic.severity.HINT]  = "󰌵 ",
      }
    '';
  };
}
