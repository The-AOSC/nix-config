{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.unp.enable = lib.mkEnableOption "unp";
  };
  config = lib.mkIf config.modules.unp.enable {
    home.packages = [
      (pkgs.unp.override (prev: {
        extraBackends =
          [
            pkgs.p7zip
            (pkgs.writeShellScriptBin "unrar" ''
              exec -a "$0" ${pkgs.unrar-free}/bin/unrar-free "$@"
            '')
          ]
          ++ prev.extraBackends or [];
      }))
    ];
  };
}
