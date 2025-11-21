{
  modules.netConfig = {
    networks = {
      home-wifi = {
        secrets."nm-home" = ./secrets/nm-home.env;
        connection.type = "wifi";
        wifi.mode = "infrastructure";
        wifi.ssid = "$HOME_SSID";
        wifi-security.auth-alg = "open";
        wifi-security.key-mgmt = "wpa-psk";
        wifi-security.psk = "$HOME_PSK";
      };
      phone = {
        secrets."nm-phone" = ./secrets/nm-phone.env;
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
