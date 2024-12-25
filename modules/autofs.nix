{options, config, lib, ...}: {
  modules.options.autofs = {
    userPackages = [];
    extraOptions = {
      /* TODO: <from configuration.nix(5):>
      services.autofs.autoMaster
          Contents of ‘/etc/auto.master’ file. See auto.master(5) and autofs(5).

          Type: string

          Example:

              let
                mapConf = pkgs.writeText "auto" ''
                 kernel    -ro,soft,intr       ftp.kernel.org:/pub/linux
                 boot      -fstype=ext2        :/dev/hda1
                 windoze   -fstype=smbfs       ://windoze/c
                 removable -fstype=ext2        :/dev/hdd
                 cd        -fstype=iso9660,ro  :/dev/hdc
                 floppy    -fstype=auto        :/dev/fd0
                 server    -rw,hard,intr       / -ro myserver.me.org:/ \
                                               /usr myserver.me.org:/usr \
                                               /home myserver.me.org:/home
                '';
              in ''
                /auto file:${mapConf}
              ''

          Declared by:
              <nixpkgs/nixos/modules/services/misc/autofs.nix>
      */
      autoMaster = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = options.services.autofs.autoMaster.example;
      };
    };
  };
  services.autofs = config.modules.lib.withModuleSystemConfig "autofs" {
    enable = true;
    autoMaster = config.modules.modules.autofs.autoMaster;
  };
}
