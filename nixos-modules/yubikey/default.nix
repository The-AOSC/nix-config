{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.yubikey.enable = lib.mkEnableOption "yubikey";
  };
  config = lib.mkIf config.modules.yubikey.enable {
    environment.systemPackages = with pkgs; [
      yubikey-manager
    ];
    services.pcscd.enable = true;
  };
}
