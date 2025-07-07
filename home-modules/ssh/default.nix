{
  config,
  lib,
  ...
}: {
  options = {
    modules.ssh.enable = lib.mkEnableOption "ssh";
  };
  config = lib.mkIf config.modules.ssh.enable {
    home.activation = {
      force-private-ssh = lib.hm.dag.entryAfter ["writeBoundary" "createAndMountPersistentStoragePaths"] ''
        run chmod -077 /persist/home/aosc/.ssh
      '';
    };
    home.persistence."/persist/home/aosc" = {
      directories = [
        ".ssh"
      ];
    };
  };
}
