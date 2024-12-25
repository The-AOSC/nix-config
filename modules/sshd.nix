{config, options, lib, ...}: {
  modules.options.sshd = {
    userPackages = [];
    persist.system.data.files = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
    extraOptions = {
      ports = lib.mkOption {
        default = options.services.openssh.ports.default;
        type = options.services.openssh.ports.type;
        description = options.services.openssh.ports.description;
      };
    };
  };
  services.openssh = config.modules.lib.withModuleSystemConfig "sshd" {
    enable = true;
    allowSFTP = true;
    authorizedKeysInHomedir = false;
    ports = config.modules.modules.sshd.ports;
    openFirewall = true;
    settings = {
      AllowGroups = ["users"];
      AllowUsers = config.modules.lib.withModuleUserConfig "sshd" (user-name: [user-name]);
      PubkeyAuthentication = true;
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      UsePAM = true;
      PermitRootLogin = "no";
    };
  };
  users.users = config.modules.lib.withModuleUserConfig "sshd" (user-name: {
    "${user-name}".openssh.authorizedKeys.keyFiles = [
      ./../credentials/${user-name}.authorized_keys
    ];
  });
}
