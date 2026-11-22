{ pkgs, csBraceAttach, roslynWrapper, hyprStubs ? true }:
{
  plugins = {
    lazydev = {
      enable = true;
      settings.library = [
        { path = "\${3rd}/luv/library"; words = [ "vim%.uv" ]; }
        { path = "snacks.nvim"; words = [ "Snacks" ]; }
      ];
    };

    inc-rename.enable = true;

    lsp = {
      enable = true;
      keymaps = {
        diagnostic = {
          "<leader>cd" = "open_float";
          "[d" = "goto_prev";
          "]d" = "goto_next";
        };
        lspBuf = {
          "gd" = "definition";
          "gD" = "declaration";
          "gr" = "references";
          "gI" = "implementation";
          "gy" = "type_definition";
          "<leader>K" = "hover";
          "<leader>ca" = "code_action";
        };
      };
      servers = {
        clangd.enable = true;
        cmake.enable = true;
        gopls.enable = true;
        jsonls.enable = true;
        yamlls.enable = true;
        html.enable = true;
        cssls.enable = true;
        dockerls.enable = true;
        docker_compose_language_service.enable = true;
        taplo.enable = true;
        marksman.enable = true;
        nil_ls.enable = true;
        zls.enable = true;
        vtsls.enable = true;
        pyright.enable = true;
        bashls.enable = true;
        tinymist.enable = true; # Typst LSP (pairs with typst-preview-nvim)
        lua_ls = {
          enable = true;
          settings.Lua = {
            diagnostics.globals = [ "vim" "hl" "Snacks" ];
            workspace = {
              checkThirdParty = false;
              library = pkgs.lib.optionals hyprStubs [ "${pkgs.hyprland}/share/hypr/stubs" ];
            };
            hint.enable = true;
            telemetry.enable = false;
          };
        };
        sqlls = {
          enable = true;
          package = null;
        };
      };
    };

    # Roslyn LS (C# 14 / .NET 10) with full analyzers, decompilation & inlay hints
    roslyn = {
      enable = true;
      settings = {
        cmd = [
          "${roslynWrapper}/bin/roslyn-language-server"
          "--logLevel=Information"
          "--extensionLogDirectory=/tmp/roslyn/logs"
        ];
        settings = {
          "csharp|inlay_hints" = {
            csharp_enable_inlay_hints_for_implicit_object_creation = true;
            csharp_enable_inlay_hints_for_implicit_variable_types = true;
            csharp_enable_inlay_hints_for_lambda_parameter_types = true;
            csharp_enable_inlay_hints_for_types = true;
            dotnet_enable_inlay_hints_for_literal_parameters = true;
            dotnet_enable_inlay_hints_for_parameters = true;
            dotnet_suppress_inlay_hints_for_parameters_that_match_argument_name = true;
          };
          "csharp|code_lens".dotnet_enable_references_code_lens = true;
          RoslynExtensions = {
            enableAnalyzers = true;
            enableDecompilationSupport = true;
          };
        };
      };
    };

    rustaceanvim = {
      enable = true;
      settings.server.standalone = true;
    };
    jdtls.enable = true;

    # Formatting — preserves Dyna's exact C# K&R same-line brace pipeline + adds Nix/Lua/Bash
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
            command = "${pkgs.csharpier}/bin/csharpier";
            args = [ "format" "--stdin-path" "$FILENAME" ];
          };
          clang-format-cs = {
            command = "${csBraceAttach}/bin/cs-brace-attach";
            args = [ ];
          };
        };
      };
    };

    lint = {
      enable = true;
      lintersByFt = {
        javascript = [ "eslint" ];
        typescript = [ "eslint" ];
        javascriptreact = [ "eslint" ];
        typescriptreact = [ "eslint" ];
      };
    };
  };
}
