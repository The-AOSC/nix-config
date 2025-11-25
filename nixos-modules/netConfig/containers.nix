{
  config,
  lib,
  ...
}: let
  cfg = config.modules.netConfig;
  containerNames = lib.attrNames config.containers;
in {
  options = {
    containers = lib.mkOption {
      type = with lib.types;
        attrsOf (submodule ({name, ...}: {
          config = let
            index = (lib.lists.findFirstIndex (n: name == name) (throw "Cannot figure out index of container ${name}") containerNames) + 1;
          in
            lib.mkIf cfg.enable {
              privateNetwork = true;
              hostAddress = "10.253.0.${builtins.toString index}";
              hostAddress6 = "fd10::${builtins.toString index}";
              localAddress = "10.253.128.${builtins.toString index}";
              localAddress6 = "fd11::${builtins.toString index}";
            };
        }));
    };
  };
  config = lib.mkIf cfg.enable {
    networking.hosts = lib.mkMerge [
      {
        "127.0.0.3" = containerNames;
        "::1" = containerNames;
      }
      # IPv4 handled by default
      (lib.mapAttrs' (name: container: lib.nameValuePair container.localAddress6 ["${name}.containers"]) config.containers)
    ];
  };
}
