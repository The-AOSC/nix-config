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
      enableNmbd = true;
      securityType = "user";
      extraConfig = ''
        unix extensions = yes
        allow insecure wide links = yes
        wide links = no
        acl allow execute always = yes
      '';
      shares = config.modules.lib.withModuleUserConfig "samba" (user-name: {
        "${user-name}" = {
          comment = "${user-name}";
          path = "${config.users.users."${user-name}".home}/smb";
          "valid users" = "${user-name}";
          public = "no";
          writable = "yes";
          "read only" = "no";
          printable = "no";
          "create mask" = "0755";
        };
        "${user-name}-ro" = {
          comment = "${user-name} readonly";
          path = "${config.users.users."${user-name}".home}/smbro";
          "valid users" = "${user-name}";
          public = "no";
          writable = "no";
          "read only" = "yes";
          printable = "no";
          "create mask" = "0755";
          "wide links" = "yes";
        };
      });
    };
    samba-wsdd = {
      enable = true;
      openFirewall = true;
    };
  };
}
