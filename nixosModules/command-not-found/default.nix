{
  inputs,
  config,
  lib,
  ...
}: {
  imports = [
    inputs.flake-programs-sqlite.nixosModules.programs-sqlite
  ];
  options = {
    modules.command-not-found.enable = lib.mkEnableOption "command-not-found";
  };
  config = let
    enable = config.modules.command-not-found.enable;
  in {
    programs.command-not-found.enable = lib.mkIf enable true;
    programs-sqlite.enable = lib.mkMerge [
      (lib.mkIf enable true)
      (lib.mkIf (!enable) (lib.mkDefault false))
    ];
  };
}
