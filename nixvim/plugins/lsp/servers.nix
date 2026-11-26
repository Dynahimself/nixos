{ pkgs, hyprStubs ? true }:

{
  plugins = {
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
        tinymist.enable = true;
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
  };
}
