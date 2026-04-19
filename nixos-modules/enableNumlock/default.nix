{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.enableNumlock.enable = lib.mkEnableOption "enableNumlock";
  };
  config = lib.mkIf config.modules.enableNumlock.enable {
    boot.initrd.preLVMCommands = lib.mkIf (!config.boot.initrd.systemd.enable) ''
      for tty in ${lib.concatMapStringsSep " " (n: "/dev/tty${builtins.toString n}") (lib.range 1 63)}; do
        ${pkgs.kbd}/bin/setleds -D +num < "$tty";
      done
    '';
    boot.initrd.systemd.services.enableNumlock = {
      before = ["cryptsetup.target"];
      wantedBy = ["initrd.target"];
      script = ''
        for tty in ${lib.concatMapStringsSep " " (n: "/dev/tty${builtins.toString n}") (lib.range 1 63)}; do
          ${pkgs.kbd}/bin/setleds -D +num < "$tty";
        done
      '';
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
    };
  };
}
