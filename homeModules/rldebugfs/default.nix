{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.rldebugfs.enable = lib.mkEnableOption "rldebugfs";
  };
  config = lib.mkIf config.modules.rldebugfs.enable {
    home.packages = [
      (pkgs.writeShellScriptBin "rldebugfs" ''
        export DEBUGFS_PAGER=${pkgs.bat}/bin/bat
        exec ${pkgs.rlwrap}/bin/rlwrap --no-children ${pkgs.e2fsprogs}/bin/debugfs "$@"
      '')
    ];
  };
}
