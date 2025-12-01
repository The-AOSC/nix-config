{
  config,
  lib,
  ...
}: {
  options = {
    profiles.home = lib.mkEnableOption "home";
  };
  config = lib.mkIf config.profiles.home {
    profiles.base = lib.mkDefault true;
    profiles.local = lib.mkDefault true;
    modules.netConfig.networks = {
      home-wifi = {
        secrets."nm-home" = ../../secrets/nm-home.env;
        connection.type = "wifi";
        wifi.mode = "infrastructure";
        wifi.ssid = "$HOME_SSID";
        wifi-security.auth-alg = "open";
        wifi-security.key-mgmt = "wpa-psk";
        wifi-security.psk = "$HOME_PSK";
      };
    };
  };
}
