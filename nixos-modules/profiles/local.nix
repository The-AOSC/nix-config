{
  inputs,
  config,
  lib,
  ...
}: {
  options = {
    profiles.local = lib.mkEnableOption "local";
  };
  imports = [(inputs.self.aspects.secrets._.networkSecret "nm-phone").modules.nixos];
  config = lib.mkIf config.profiles.local {
    profiles.base = lib.mkDefault true;
    modules.enableNumlock.enable = lib.mkDefault true;
    modules.theme.enable = lib.mkDefault true;
    modules.netConfig.networks = {
      phone = {
        secrets."nm-phone" = null;
        connection.type = "wifi";
        wifi.mtu = "1400"; # fixes SSL erros
        wifi.mode = "infrastructure";
        wifi.ssid = "$PHONE_SSID";
        wifi-security.auth-alg = "open";
        wifi-security.key-mgmt = "wpa-psk";
        wifi-security.psk = "$PHONE_PSK";
      };
    };
  };
}
