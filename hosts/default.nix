args @ {nixpkgs, ...}: let
  inherit (nixpkgs) lib;
in
  lib.mapAttrs (path: type: (import (./. + "/${path}") args))
  (lib.filterAttrs
    (path: type: (type == "directory"))
    (builtins.readDir ./.))
