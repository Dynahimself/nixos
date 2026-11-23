{ config, lib, pkgs, ... }:

let
  cfg = config.dyna.nixvim;

  # Attach K&R braces after csharpier
  csBraceAttach = pkgs.writeShellScriptBin "cs-brace-attach" ''
    set -euo pipefail
    exec ${pkgs.clang-tools}/bin/clang-format \
      --assume-filename=file.cs \
      --style='{BasedOnStyle: LLVM, IndentWidth: 4, BreakBeforeBraces: Attach, ColumnLimit: 100, BreakBeforeBinaryOperators: All, AlignOperands: Align, FixNamespaceComments: false, AccessModifierOffset: -4, IndentCaseLabels: false, AllowShortFunctionsOnASingleLine: None, AllowShortIfStatementsOnASingleLine: false, Language: CSharp}'
  '';

  # Strip --daemon-mode flag passed by nvim 0.12
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
    enable = lib.mkEnableOption "Nixvim editor";
    hyprStubs = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include Hyprland Lua LSP stubs";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      enable = true;

      imports = [
        (import ./nixvim/options.nix { inherit pkgs; })
        (import ./nixvim/keymaps.nix { inherit pkgs; })
        (import ./nixvim/ui.nix { inherit pkgs; })
        (import ./nixvim/coding.nix { inherit pkgs; })
        (import ./nixvim/lsp.nix { inherit pkgs csBraceAttach roslynWrapper; hyprStubs = cfg.hyprStubs; })
        (import ./nixvim/git-debug.nix { inherit pkgs; })
        (import ./nixvim/commands.nix { inherit pkgs; })
        (import ./nixvim/motion-coach.nix { inherit pkgs; })
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
