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
      pkgs.kdePackages.kdeconnect-kde
    ];
    home.persistence."/persist/home/aosc" = {
      directories = [
        ".config/kdeconnect"
      ];
    };
  };
}
