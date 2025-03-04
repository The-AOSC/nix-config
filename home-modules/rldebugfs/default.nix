{pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellScriptBin "rldebugfs" ''
      export DEBUGFS_PAGER=${pkgs.bat}/bin/bat
      exec ${pkgs.rlwrap}/bin/rlwrap --no-children ${pkgs.e2fsprogs}/bin/debugfs "$@"
    '')
  ];
}
