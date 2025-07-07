{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.endgame-singularity.enable = lib.mkEnableOption "endgame-singularity";
  };
  config = lib.mkIf config.modules.endgame-singularity.enable {
    home.packages = [
      pkgs.endgame-singularity
    ];
    home.persistence."/persist/home/aosc" = {
      directories = [
        ".config/singularity"
        ".local/share/singularity"
      ];
    };
  };
}
