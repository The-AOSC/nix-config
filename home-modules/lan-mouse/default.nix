{
  inputs,
  config,
  lib,
  ...
}: {
  options = {
    modules.lan-mouse.enable = lib.mkEnableOption "lan-mouse";
  };
  imports = [
    inputs.lan-mouse.homeManagerModules.default
  ];
  config = lib.mkIf config.modules.lan-mouse.enable {
    programs.lan-mouse = {
      enable = true;
      systemd = false;
      settings = {
        port = 4242;
      };
    };
    home.persistence."/persist" = {
      directories = [
        ".config/lan-mouse"
      ];
    };
  };
}
