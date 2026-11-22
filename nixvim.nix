# =====================================================================
# Nixvim — Dyna's Colemak-DH Catppuccin Mocha Neovim 0.12 Workbench
# =====================================================================
# Modularized under ./nixvim/{options,keymaps,ui,coding,lsp,git-debug,commands}.nix
# Activation: `dyna.nixvim.enable = true` in home.nix / home-wsl.nix.
# =====================================================================
{ config, lib, pkgs, ... }:

let
  cfg = config.dyna.nixvim;

  # Pass 2 of C# formatting: attach K&R same-line braces after csharpier.
  csBraceAttach = pkgs.writeShellScriptBin "cs-brace-attach" ''
    set -euo pipefail
    exec ${pkgs.clang-tools}/bin/clang-format \
      --assume-filename=file.cs \
      --style='{BasedOnStyle: LLVM, IndentWidth: 4, BreakBeforeBraces: Attach, ColumnLimit: 100, BreakBeforeBinaryOperators: All, AlignOperands: Align, FixNamespaceComments: false, AccessModifierOffset: -4, IndentCaseLabels: false, AllowShortFunctionsOnASingleLine: None, AllowShortIfStatementsOnASingleLine: false, Language: CSharp}'
  '';

  # Wrapper for Roslyn LS: strips --daemon-mode (nvim 0.12's lsp/roslyn.lua passes it).
  roslynWrapper = pkgs.writeShellScriptBin "roslyn-language-server" ''
    args=()
    for a in "$@"; do
      [ "$a" = "--daemon-mode" ] && continue
      args+=("$a")
    done
    exec ${pkgs.roslyn-ls}/bin/Microsoft.CodeAnalysis.LanguageServer "''${args[@]}"
  '';
in
{
  options.dyna.nixvim = {
    enable = lib.mkEnableOption "Nixvim editor (Colemak-DH workbench)";
  };

  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      enable = true;

      imports = [
        (import ./nixvim/options.nix { inherit pkgs; })
        (import ./nixvim/keymaps.nix { inherit pkgs; })
        (import ./nixvim/ui.nix { inherit pkgs; })
        (import ./nixvim/coding.nix { inherit pkgs; })
        (import ./nixvim/lsp.nix { inherit pkgs csBraceAttach roslynWrapper; })
        (import ./nixvim/git-debug.nix { inherit pkgs; })
        (import ./nixvim/commands.nix { inherit pkgs; })
      ];

      extraPlugins = with pkgs.vimPlugins; [
        otter-nvim
        vim-dadbod
        vim-dadbod-ui
        vim-dadbod-completion
        presence-nvim
        ts-comments-nvim
        markdown-preview-nvim
        typst-preview-nvim
        hardtime-nvim
        nui-nvim
        friendly-snippets
      ];

      extraPackages = with pkgs; [
        prettier
        black
        eslint
        csharpier
        clang-tools
        nixfmt
        stylua
        shfmt
        csBraceAttach
        roslynWrapper
      ];
    };
  };
}
