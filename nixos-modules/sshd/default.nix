{
  config,
  lib,
  ...
}: {
  options = {
    modules.sshd.enable = lib.mkEnableOption "sshd";
  };
  config = lib.mkIf config.modules.sshd.enable {
    services.openssh = {
      enable = true;
      allowSFTP = true;
      authorizedKeysInHomedir = false;
      openFirewall = true;
      settings = {
        AllowGroups = ["users"];
        PubkeyAuthentication = true;
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        UsePAM = true;
        PermitRootLogin = "no";
      };
      hostKeys = [
        {
          type = "rsa";
          bits = 4096;
          path = "/persist/etc/ssh/ssh_host_rsa_key";
        }
        {
          type = "ed25519";
          path = "/persist/etc/ssh/ssh_host_ed25519_key";
        }
      ];
    };
  };
}
