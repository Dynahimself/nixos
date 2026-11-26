{ ... }:

{
  plugins = {
    neotest = {
      enable = true;
      adapters = {
        dotnet.enable = true;
        python.enable = true;
        go.enable = true;
        rust.enable = true;
      };
      settings = {
        output.open_on_run = false;
        summary.mappings = {
          expand = [ "<CR>" "o" ];
          jumpto = "O";
          next_failed = "]t";
          prev_failed = "[t";
        };
      };
    };
  };
}
