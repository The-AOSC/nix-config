{
  pkgs,
  lib,
  ...
}: {
  boot.initrd.preLVMCommands = ''
    for tty in ${lib.concatMapStringsSep " " (n: "/dev/tty${builtins.toString n}") (lib.range 1 63)}; do
      ${pkgs.kbd}/bin/setleds -D +num < "$tty";
    done
  '';
}
