{ ... }:

{
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      style = "compact";
      inline_height = 18;
      search_mode = "fuzzy";
    };
  };
}
