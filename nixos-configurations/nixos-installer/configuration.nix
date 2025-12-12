{lib, ...}: {
  disko.enableConfig = false;
  users.users.root.openssh.authorizedKeys.keyFiles = [
    ../../credentials/aosc.authorized_keys
  ];
  modules.sshd.enable = true;
  services.openssh = {
    authorizedKeysInHomedir = lib.mkForce true; # nixos-anywhere compatibility
    settings = {
      AllowGroups = lib.mkForce null;
      PermitRootLogin = lib.mkForce "prohibit-password";
    };
  };
  modules.netConfig = {
    enable = true;
    advertiseContainers = false;
  };
  services.avahi.publish = {
    enable = lib.mkForce false;
    addresses = lib.mkForce false;
  };
  nixpkgs.hostPlatform = "x86_64-linux";
}
