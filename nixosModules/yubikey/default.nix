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
    services.udev.extraRules = ''
      ACTION=="remove",\
       ENV{ID_BUS}=="usb",\
       ENV{ID_MODEL_ID}=="0407",\
       ENV{ID_VENDOR_ID}=="1050",\
       ENV{ID_VENDOR}=="Yubico",\
       RUN+="${pkgs.systemd}/bin/loginctl lock-sessions"
    '';
  };
}
