{ pkgs, ... }:

{
  # ---- ProtonVPN (split tunnel: only qbittorrent traffic goes through wg0) ----
  boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  systemd.services.protonvpn-wg0 = {
    description = "ProtonVPN wg0 (split tunnel, qbittorrent only)";
    wants = [ "network-online.target" ];
    after = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ iproute2 iptables wireguard-tools ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "wg0-up" ''
        key=$(cat /etc/protonvpn/privatekey)
        cat > /run/wg0.conf <<EOF
        [Interface]
        PrivateKey = $key
        Table = off
        FwMark = 4242
        Address = 10.2.0.2/32
        MTU = 1420

        [Peer]
        PublicKey = R0J2HK9bYV4Ww6tMk76hiTwiWbC6JvxqhvSNeO4tIhg=
        AllowedIPs = 0.0.0.0/0
        Endpoint = 151.243.141.5:51820
        PersistentKeepalive = 25
        EOF
        chmod 600 /run/wg0.conf
        wg-quick up /run/wg0.conf
        ip route add default dev wg0 table 100
        ip rule add to 151.243.141.5 lookup main priority 99
        ip rule add fwmark 51820 table 100 priority 100
        iptables -t mangle -A OUTPUT -m owner --uid-owner qbittorrent -j MARK --set-mark 51820
      '';
      ExecStop = pkgs.writeShellScript "wg0-down" ''
        iptables -t mangle -D OUTPUT -m owner --uid-owner qbittorrent -j MARK --set-mark 51820 2>/dev/null || true
        ip rule del fwmark 51820 table 100 2>/dev/null || true
        ip rule del to 151.243.141.5 lookup main 2>/dev/null || true
        wg-quick down /run/wg0.conf 2>/dev/null || true
      '';
    };
  };

}
