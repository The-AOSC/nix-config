{config, ...}: {
  modules.options.samba = {
    userPackages = [];
    persist.users.data.directories = [
      "/var/lib/samba"
    ];
    persist.user.data.directories = [
      "smb"
      "smbro"
    ];
  };
  services = config.modules.lib.withModuleUsersConfig "samba" {
    samba = {
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
        "vladimir" = {
          comment = "vladimir";
          path = "${config.users.users.vladimir.home}/smb";
          "valid users" = "vladimir";
          public = false;
          writable = true;
          "read only" = false;
          printable = false;
          "create mask" = "0755";
        };
        "vladimir-ro" = {
          comment = "vladimir readonly";
          path = "${config.users.users.vladimir.home}/smbro";
          "valid users" = "vladimir";
          public = false;
          writable = false;
          "read only" = true;
          printable = false;
          "create mask" = "0755";
          "wide links" = true;
        };
      };
    };
    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
  };
}
