{lib, pkgs, ...}: {
  modules.users.vladimir.modules = {
    cifs-utils.enable = true;
    git.enable = true;
    samba.enable = true;
    net-snmp.enable = true;
    git-daemon.enable = true;
    wireshark.enable = true;
  };
  modules.modules = {
    autofs = {
      enable = true;
      autoMaster = let
        cyclone = pkgs.writeText "autofs-cyclone" ''
          /home/vladimir/cyclone-win -fstype=smb3,defaults,username=user,password=1,domainauto,uid=vladimir,gid=users ://192.168.2.146/Users/user/Desktop/cyclone/cyclone_base
        '';
      in ''
        /- file:${cyclone} browse --timeout 60
      '';
    };
    git-daemon.enable = true;
    ntp.enable = true;
    wireshark.enable = true;
  };
  services.syslog-ng = {
    enable = true;
    # TODO: multitail syslog colorscheme doesn't work with iso timestamp format
    extraConfig = ''
      options {
        #ts-format(iso);
      };
      source s_net {
        syslog(ip(0.0.0.0), port(514), transport("udp"), flags(store-raw-message));
      };
      destination remote-log {
        file("/var/log/remote-log", perm(0644));
      };
      template-function raw-format "$(padding \"''${FACILITY}.''${LEVEL}\" 20) ''${RAWMSG}\n";
      destination remote-raw-log {
        file("/var/log/remote-raw-log", perm(0644), template("$(raw-format)"));
      };
      log {
        source(s_net);
        destination(remote-log); destination(remote-raw-log);
      };
    '';
  };
  services.ntp.extraConfig = ''
    # For relion router SNMP testing
    restrict 192.168.0.0 mask 255.255.255.0 nomodify notrap
  '';
  networking.firewall.allowedUDPPorts = [
    514  # syslog
  ];
  environment.persistence."/persist/storage".users.vladimir = {
    directories = [
      "Desktop/apps"
    ];
  };
  #boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
  networking.nat = {
    enable = true;
    externalInterface = "wlo1";
    internalInterfaces = [
      "enp0s20f0u2"
    ];
  };
}
