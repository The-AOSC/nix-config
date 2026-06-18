{
  flake.aspects = {aspects, ...}: {
    base.includes = [aspects.base._.static-ids];
    base._.static-ids.nixos = {
      config,
      lib,
      ...
    }: {
      options = {
        users.users = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
            uid = let
              id = config.ids.uids.${name} or null;
            in
              lib.mkIf (id != null) (lib.mkDefault id);
          }));
        };
        users.groups = lib.mkOption {
          type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
            gid = let
              id = config.ids.gids.${name} or null;
            in
              lib.mkIf (id != null) (lib.mkDefault id);
          }));
        };
      };
      config = {
        ids = {
          uids = {
            copyparty = 986;
            avahi = 990;
            borg = 991;
            mandb = 992;
            nm-iodine = 993;
            nscd = 994;
            ntp = 995;
            pcscd = 996;
            sshd = 997;
            systemd-oom = 998;
            wpa_supplicant = 999;
            aosc = 1000;
          };
          gids = {
            copyparty = 982;
            avahi = 986;
            mandb = 987;
            borg = 988;
            nscd = 989;
            ntp = 990;
            pcscd = 991;
            polkituser = 992;
            resolvconf = 993;
            sshd = 994;
            systemd-coredump = 995;
            systemd-oom = 996;
            uinput = 997;
            wireshark = 998;
            wpa_supplicant = 999;
          };
        };
        assertions = let
          usersWithoutUid = lib.attrNames (lib.filterAttrs (n: u: u.uid == null) config.users.users);
          groupsWithoutGid = lib.attrNames (lib.filterAttrs (n: g: g.gid == null) config.users.groups);
        in [
          {
            assertion = usersWithoutUid == [];
            message = ''
              The following users are missing a uid (add them to modules/users/static-ids.nix):
              ${lib.concatStringsSep " " usersWithoutUid}
            '';
          }
          {
            assertion = groupsWithoutGid == [];
            message = ''
              The following groups are missing a uid (add them to modules/users/static-ids.nix):
              ${lib.concatStringsSep " " groupsWithoutGid}
            '';
          }
        ];
      };
    };
  };
}
