{
  config,
  lib,
  ...
}: {
  options = {
    profiles.server = lib.mkEnableOption "server";
  };
  config = lib.mkIf config.profiles.server {
    profiles.base = lib.mkDefault true;
    profiles.headless = lib.mkDefault true;
    users.users.root = {
      openssh.authorizedKeys.keyFiles = [
        ../../credentials/aosc.authorized_keys
      ];
    };
    services.openssh.settings = {
      AllowGroups = lib.mkForce null;
      PermitRootLogin = lib.mkForce "prohibit-password";
    };
  };
}
