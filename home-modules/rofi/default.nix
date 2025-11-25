{
  config,
  lib,
  ...
}: {
  options = {
    modules.rofi.enable = lib.mkEnableOption "rofi";
  };
  imports = [
    ./power.nix
  ];
  config = lib.mkIf config.modules.rofi.enable {
    programs.rofi = {
      enable = true;
      terminal = "${config.programs.kitty.package}/bin/kitty --single-instance";
      modes = [
        "drun"
      ];
      extraConfig = {
        show-icons = true;
      };
    };
  };
}
