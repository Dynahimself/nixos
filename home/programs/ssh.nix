{ ... }:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "raspberrypi pi" = {
        hostname = "100.68.54.112";
        user = "dyna";
      };
      "nas" = {
        hostname = "100.97.162.110";
        user = "dyna";
      };
      "laptop" = {
        hostname = "100.116.179.60";
        user = "dyna";
      };
      "desktop desktop-1" = {
        hostname = "100.89.63.116";
        user = "dyna";
      };
      "github.com" = {
        hostname = "ssh.github.com";
        port = 443;
        user = "git";
      };
      "*" = {
        serverAliveInterval = 60;
        serverAliveCountMax = 3;
      };
    };
  };
}
