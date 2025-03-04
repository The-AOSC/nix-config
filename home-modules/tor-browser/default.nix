{osConfig, pkgs, ...}: {
  home.packages = [
    (pkgs.writeShellScriptBin "tor-browser" ''
      export TOR_SKIP_LAUNCH=1
      export TOR_SOCKS_PORT=${builtins.toString osConfig.services.tor.client.socksListenAddress.port}
      export TOR_CONTROL_PORT=${builtins.toString osConfig.services.tor.settings.ControlPort}
      export TOR_CONTROL_COOKIE_AUTH_FILE=${osConfig.services.tor.settings.CookieAuthFile}
      exec -a "$0" ${pkgs.tor-browser}/bin/tor-browser "$@"
    '')
  ];
  home.persistence."/persist/home/aosc" = {
    directories = [
      ".tor project"
    ];
  };
}
