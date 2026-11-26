{ ... }:

{
  environment.etc."hypr/monitor.conf".text = ''
    monitor = eDP-1, 1920x1080@144, 0x0, 1
  '';

  #  environment.etc."hypr/monitor.conf".text = ''
  #    input {
  #      kb_layout = us
  #      kb_variant = colemak_dh
  #    }
  #  '';

  #  services.xserver.xkb = {
  #    layout = "us";
  #    variant = "colemak_dh";
  #  };
}
