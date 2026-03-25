{
  flake.aspects = {aspects, ...}: {
    user._.root = {
      provides.local.includes = [(aspects.users "root")._.sops-password];
      provides.remote.user.openssh.authorizedKeys.keyFiles = [
        ../../credentials/aosc.authorized_keys
      ];
    };
  };
}
