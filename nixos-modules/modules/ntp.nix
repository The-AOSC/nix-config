{config, ...}: {
  modules.options.ntp = {
    userPackages = [];
  };
  /*
  # default value
  networking.timeServers = [
    "0.nixos.pool.ntp.org"
    "1.nixos.pool.ntp.org"
    "2.nixos.pool.ntp.org"
    "3.nixos.pool.ntp.org"
  ];
  */
  services.ntp = config.modules.lib.withModuleSystemConfig "ntp" {
    enable = true;
    #servers = [];
    extraConfig = ''
      # Allow machines within network to synchronize their clocks
      #restrict 192.168.1.0 mask 255.255.255.0 nomodify notrap

      # Use local time when connectivity is lost
      server 127.127.1.0
      fudge 127.127.1.0 stratum 10
    '';
  };
  networking.firewall.allowedTCPPorts = config.modules.lib.withModuleSystemConfig "ntp" [
    123  # NTP
  ];
  networking.firewall.allowedUDPPorts = config.modules.lib.withModuleSystemConfig "ntp" [
    123  # NTP
  ];
}
