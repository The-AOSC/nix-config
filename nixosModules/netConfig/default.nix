{
  config,
  lib,
  ...
}: let
  cfg = config.modules.netConfig;
in {
  imports = [
    ./containers.nix
    ./networkProfiles.nix
  ];
  options.modules.netConfig = {
    enable = lib.mkEnableOption "netConfig";
  };
}
