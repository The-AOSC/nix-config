{pkgs, ...}: {
  services.tor = {
    enable = true;
    client = {
      enable = true;
      dns.enable = true;
      # for tor browser
      socksListenAddress = {
        IsolateDestAddr = true;
        KeepAliveIsolateSOCKSAuth = true;
        IPv6Traffic = true;
        PreferIPv6 = true;
        addr = "127.0.0.1";
        port = 9150;
      };
    };
    settings = {
      UseBridges = "1";
      #ClientTransportPlugin = "snowflake exec ${pkgs.snowflake}/client";
      ClientTransportPlugin = "snowflake exec ${pkgs.tor-browser}/share/tor-browser/TorBrowser/Tor/PluggableTransports/snowflake-client";
      Bridge = [
        "snowflake 192.0.2.5:80 2B280B23E1107BB62ABFC40DDCC8824814F80A72 fingerprint=2B280B23E1107BB62ABFC40DDCC8824814F80A72 url=https://snowflake-broker.torproject.net/ ampcache=https://cdn.ampproject.org/ front=www.google.com ice=stun:stun.antisip.com:3478,stun:stun.epygi.com:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.mixvoip.com:3478,stun:stun.nextcloud.com:3478,stun:stun.bethesda.net:3478,stun:stun.nextcloud.com:443 utls-imitate=hellorandomizedalpn"
        "snowflake 192.0.2.3:80 2B280B23E1107BB62ABFC40DDCC8824814F80A72 fingerprint=2B280B23E1107BB62ABFC40DDCC8824814F80A72 url=https://1098762253.rsc.cdn77.org fronts=www.phpmyadmin.net,cdn.zk.mk ice=stun:stun.antisip.com:3478,stun:stun.epygi.com:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.mixvoip.com:3478,stun:stun.nextcloud.com:3478,stun:stun.bethesda.net:3478,stun:stun.nextcloud.com:443 utls-imitate=hellorandomizedalpn"
        "snowflake 192.0.2.4:80 8838024498816A039FCBBAB14E6F40A0843051FA fingerprint=8838024498816A039FCBBAB14E6F40A0843051FA url=https://1098762253.rsc.cdn77.org fronts=www.phpmyadmin.net,cdn.zk.mk ice=stun:stun.antisip.com:3478,stun:stun.epygi.com:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.mixvoip.com:3478,stun:stun.nextcloud.com:3478,stun:stun.bethesda.net:3478,stun:stun.nextcloud.com:443 utls-imitate=hellorandomizedalpn"
        "snowflake 192.0.2.6:80 8838024498816A039FCBBAB14E6F40A0843051FA fingerprint=8838024498816A039FCBBAB14E6F40A0843051FA url=https://snowflake-broker.torproject.net/ ampcache=https://cdn.ampproject.org/ front=www.google.com ice=stun:stun.antisip.com:3478,stun:stun.epygi.com:3478,stun:stun.uls.co.za:3478,stun:stun.voipgate.com:3478,stun:stun.mixvoip.com:3478,stun:stun.nextcloud.com:3478,stun:stun.bethesda.net:3478,stun:stun.nextcloud.com:443 utls-imitate=hellorandomizedalpn"
      ];
      ControlPort = 9051;
      CookieAuthentication = true;
      CookieAuthFileGroupReadable = true;
      CookieAuthFile = "/run/tor/control.authcookie";
      SOCKSPort = [
        # for torsocks (doesn't work with IPv6)
        {
          IsolateDestAddr = true;
          KeepAliveIsolateSOCKSAuth = true;
          IPv6Traffic = false;
          addr = "127.0.0.1";
          port = 9050;
        }
      ];
    };
  };
  users.users.vladimir.extraGroups = [
    "tor"
  ];
}
