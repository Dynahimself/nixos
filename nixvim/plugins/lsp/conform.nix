{ hmPkgs, ... }:

let
  # Attach K&R braces after csharpier
  csBraceAttach = hmPkgs.writeShellScriptBin "cs-brace-attach" ''
    set -euo pipefail
    exec ${hmPkgs.clang-tools}/bin/clang-format \
      --assume-filename=file.cs \
      --style='{BasedOnStyle: LLVM, IndentWidth: 4, BreakBeforeBraces: Attach, ColumnLimit: 100, BreakBeforeBinaryOperators: All, AlignOperands: Align, FixNamespaceComments: false, AccessModifierOffset: -4, IndentCaseLabels: false, AllowShortFunctionsOnASingleLine: None, AllowShortIfStatementsOnASingleLine: false, Language: CSharp}'
  '';
in
{
  plugins = {
    # Formatters (C# runs csharpier then clang-format K&R)
    conform-nvim = {
      enable = true;
      settings = {
        format_on_save.__raw = ''
          function(bufnr)
            if vim.g.format_on_save == false then return end
            return { lsp_format = "fallback", timeout_ms = 3000 }
          end
        '';
        formatters_by_ft = {
          javascript = [ "prettier" ];
          typescript = [ "prettier" ];
          javascriptreact = [ "prettier" ];
          typescriptreact = [ "prettier" ];
          css = [ "prettier" ];
          html = [ "prettier" ];
          json = [ "prettier" ];
          yaml = [ "prettier" ];
          markdown = [ "prettier" ];
          python = [ "black" ];
          nix = [ "nixfmt" ];
          lua = [ "stylua" ];
          sh = [ "shfmt" ];
          bash = [ "shfmt" ];
          cs = [ "csharpier-stdin" "clang-format-cs" ];
          cshtml = [ "csharpier-stdin" "clang-format-cs" ];
          c = [ "clang-format" ];
          cpp = [ "clang-format" ];
          objc = [ "clang-format" ];
          cuda = [ "clang-format" ];
        };
        formatters = {
          csharpier-stdin = {
            command = "${hmPkgs.csharpier}/bin/csharpier";
            args = [ "format" "--stdin-path" "$FILENAME" ];
          };
          clang-format-cs = {
            command = "${csBraceAttach}/bin/cs-brace-attach";
            args = [ ];
          };
        };
      };
    };
  };

  extraPackages = with hmPkgs; [
    prettier
    black
    csharpier
    clang-tools
    nixfmt
    stylua
    shfmt
    csBraceAttach
  ];
}
