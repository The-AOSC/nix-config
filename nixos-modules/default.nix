{nixpkgs, ...}: let
  inherit (nixpkgs) lib;
in
  lib.mapAttrs' (path: type: lib.nameValuePair (lib.removeSuffix ".nix" path) (import (./. + "/${path}")))
  (lib.filterAttrs
    (path: type: (type == "directory") || ((path != "default.nix") && (lib.hasSuffix ".nix" path)))
    (builtins.readDir ./.))
