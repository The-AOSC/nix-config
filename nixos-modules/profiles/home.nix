{
  inputs,
  config,
  lib,
  ...
}: {
  options = {
    profiles.home = lib.mkEnableOption "home";
  };
  imports = [(inputs.self.aspects.secrets._.networkSecret "nm-home").modules.nixos];
  config = lib.mkIf config.profiles.home {
    profiles.base = lib.mkDefault true;
    profiles.local = lib.mkDefault true;
    modules.netConfig.networks = {
      home-wifi = {
        secrets."nm-home" = null;
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
