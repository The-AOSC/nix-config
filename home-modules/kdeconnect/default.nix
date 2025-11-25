{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.kdeconnect.enable = lib.mkEnableOption "kdeconnect";
  };
  config = lib.mkIf config.modules.kdeconnect.enable {
    home.packages = [
      (pkgs.kdePackages.kdeconnect-kde.overrideAttrs (old: {
        cmakeFlags =
          old.cmakeFlags or []
          ++ [
            "-DMDNS_ENABLED=OFF"
          ];
      }))
    ];
    home.persistence."/persist" = {
      directories = [
        ".config/kdeconnect"
      ];
    };
  };
}
