{lib, ...}: {
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
  nixpkgs.hostPlatform = "x86_64-linux";
}
