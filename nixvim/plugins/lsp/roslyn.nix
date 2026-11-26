{ hmPkgs, ... }:

let
  # Strip --daemon-mode flag passed by nvim 0.12
  roslynWrapper = hmPkgs.writeShellScriptBin "roslyn-language-server" ''
    args=()
    for a in "$@"; do
      [ "$a" = "--daemon-mode" ] && continue
      args+=("$a")
    done
    exec ${hmPkgs.roslyn-ls}/bin/Microsoft.CodeAnalysis.LanguageServer "''${args[@]}"
  '';
in
{
  plugins = {
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
  };

  extraPackages = [ roslynWrapper ];
}
