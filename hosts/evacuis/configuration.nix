{
  config,
  pkgs,
  ...
}: {
  time.timeZone = "Asia/Yekaterinburg";
  users.users.aosc = {
    hashedPasswordFile = "/etc/credentials/aosc.hashedpassword";
    openssh.authorizedKeys.keyFiles = [
      ../../credentials/aosc.authorized_keys
    ];
    isNormalUser = true;
    extraGroups = [
      "dialout"
      "networkmanager"
      #"video"
      "wheel"
      "wireshark"
    ];
    shell = pkgs.fish;
  };
  boot.binfmt.emulatedSystems = ["aarch64-linux" "armv7l-linux"];
  system.stateVersion = "25.05";
  environment.persistence."/persist" = {
    directories = [
      "/var/lib/samba"
      "/var/lib/systemd/backlight"
    ];
  };
  services.samba = {
    enable = true;
    openFirewall = true;
    nmbd.enable = true;
    settings = {
      global = {
        security = "user";
        "unix extensions" = true;
        "allow insecure wide links" = true;
        "wide links" = false;
        "acl allow execute always" = true;
      };
      "aosc" = {
        comment = "aosc";
        path = "${config.users.users.aosc.home}/smb";
        "valid users" = "aosc";
        public = false;
        writable = true;
        "read only" = false;
        printable = false;
        "create mask" = "0755";
      };
      "aosc-ro" = {
        comment = "aosc readonly";
        path = "${config.users.users.aosc.home}/smbro";
        "valid users" = "aosc";
        public = false;
        writable = false;
        "read only" = true;
        printable = false;
        "create mask" = "0755";
        "wide links" = true;
      };
    };
  };
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
  services.autofs = {
    enable = true;
    autoMaster = let
      cyclone = pkgs.writeText "autofs-cyclone" ''
        /home/aosc/cyclone-win -fstype=smb3,defaults,username=user,password=1,domainauto,uid=aosc,gid=users,actimeo=0 ://192.168.0.180/Users/user/Desktop/cyclone
      '';
    in ''
      /- file:${cyclone} browse --timeout 60
    '';
  };
  services.openssh.ports = [7132];
}
