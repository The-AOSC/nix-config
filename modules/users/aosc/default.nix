{inputs, ...}: {
  flake.aspects = {aspects, ...}: {
    user._.aosc = {
      includes = [
        (aspects.users "aosc")._.sops-password
      ];
      nixos = {pkgs, ...}: {
        users.users.aosc.shell = pkgs.fish;
      };
      user = {
        openssh.authorizedKeys.keyFiles = [
          ../../../credentials/aosc.authorized_keys
        ];
      };
      homeManager.imports = [
        ../../../home-configurations/aosc/default.nix
        inputs.self.homeModules.default
      ];
    };
  };
}
