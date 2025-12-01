{lib, ...}: {
  imports =
    lib.map (name: ./. + "/${name}")
    (lib.attrNames
      (lib.filterAttrs
        (path: type: (type == "directory") || ((path != "default.nix") && (lib.hasSuffix ".nix" path)))
        (builtins.readDir ./.)));
}
