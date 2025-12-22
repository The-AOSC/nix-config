{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (import ./base64.nix {inherit lib;}) toBase64;
  cfg = config.modules.webdav;
  dav-hostname = "${config.networking.hostName}-webdav";
  mkLocation = path: route: {
    rw ? false,
    config ? {},
  }:
    {
      directory = path;
      route = let
        routeNorm = lib.converge (lib.replaceString "//" "/") "/${route}/";
        routePath =
          if routeNorm == "/"
          then "/"
          else (lib.removeSuffix "/" routeNorm);
      in [
        "${routeNorm}*path"
        "${routePath}"
      ];
      handler = "filesystem";
      methods = [
        (
          if rw
          then "webdav-rw"
          else "webdav-ro"
        )
      ];
      autoindex = true;
      hide-symlinks = false;
      auth = "false";
    }
    // config;
  routes = lib.concatMap (location: location.route) config.services.webdav-server-rs.settings.location;
  routes-roots = lib.map (lib.removeSuffix "*path") routes;
  webdav-root = pkgs.runCommand "webdav-root" {} ''
    mkdir $out
    for route in ${lib.escapeShellArgs routes-roots}; do
      mkdir -p $out/"$route"
    done
  '';
  nginxLocationsForUser = username: {
    "/${username}" = {
      proxyPass = "http://${dav-hostname}:8888";
      extraConfig = ''
        proxy_set_header Authorization "Basic ${toBase64 "${username}:"}";
      '';
    };
    "/${username}-upload" = {
      proxyPass = "http://${dav-hostname}:8888";
      extraConfig = ''
        proxy_set_header Authorization "Basic ${toBase64 "${username}:"}";
      '';
    };
  };
  webdavLocationForUser = username: [
    (mkLocation "/home/${username}/dav" "/${username}/" {
      config = {
        auth = "true";
        setuid = true;
      };
    })
    (mkLocation "/home/${username}/dav-upload" "/${username}-upload/" {
      rw = true;
      config = {
        auth = "true";
        setuid = true;
      };
    })
  ];
  users = lib.attrNames (lib.filterAttrs (name: value: value.isNormalUser) config.users.users);
in {
  options = {
    modules.webdav.enable = lib.mkEnableOption "webdav";
  };
  config = lib.mkIf cfg.enable {
    nixpkgs.overlays = [
      (final: prev: {
        webdav-server-rs = prev.webdav-server-rs.overrideAttrs (old: {
          patches =
            old.patches or []
            ++ [
              (final.fetchpatch2 {
                url = "https://github.com/miquels/webdav-server-rs/commit/b3c426c2941034d75e267be9f55e2bd418b2caae.patch?full_index=1";
                hash = "sha256-oBEM0BTGU3O7e/R/36I17UQgNfgU9VU1/J4JJsX850s=";
              })
            ];
        });
      })
    ];
    modules.netConfig.extraHostnames = [dav-hostname];
    networking.hosts = {
      "127.0.0.3" = [dav-hostname];
      "::1" = [dav-hostname];
    };
    services.nginx = {
      enable = true;
      recommendedProxySettings = lib.mkDefault true;
      virtualHosts = let
        virtHost = {
          locations = lib.mkMerge ([
              {"/".proxyPass = "http://${dav-hostname}:8888";}
            ]
            ++ (lib.map nginxLocationsForUser users));
        };
      in {
        "${dav-hostname}" = virtHost // {default = true;};
        "${dav-hostname}.local" = virtHost;
      };
    };
    security.pam.services."permit-auth".text = ''
      auth     sufficient pam_permit.so
      account  required   pam_deny.so
      password required   pam_deny.so
      session  required   pam_deny.so
    '';
    services.webdav-server-rs = {
      enable = true;
      settings = {
        server.listen = ["127.0.0.3:8888" "[::]:8888"];
        accounts = {
          auth-type = "pam";
          acct-type = "unix";
        };
        pam.service = "permit-auth";
        location = lib.mkMerge ([
            (lib.mkAfter [(mkLocation webdav-root "/" {})])
          ]
          ++ (lib.map webdavLocationForUser users));
      };
    };
  };
}
