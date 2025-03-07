{pkgs, ...}: {
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
}
