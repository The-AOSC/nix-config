{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.wtf.enable = lib.mkEnableOption "wtf";
  };
  config = lib.mkIf config.modules.wtf.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "wtf" ''
        export ACRONYMDB="${./acronyms} ${pkgs.wtf}/share/misc/acronyms ${pkgs.wtf}/share/misc/acronyms-o.real ${pkgs.wtf}/share/misc/acronyms.comp"
        exec -a "$0" ${pkgs.wtf}/bin/wtf -o "$@"
      '')
    ];
  };
}
