{
  lib,
  nixpkgs,
  nixvim,
  symlinkJoin,
  writeShellScriptBin,
  ...
}: let
  nixvimPackage = nixvim.makeNixvim ({...}: {
    imports = [./.];
    nixpkgs.source = nixpkgs;
  });
  viewPackage = writeShellScriptBin "view" ''
    exec -a "$0" ${lib.getExe nixvimPackage.config.build.nvimPackage} -R "$@"
  '';
in
  nixvimPackage.overrideAttrs (old: {
    paths =
      old.paths
      ++ [
        viewPackage
      ];
  })
