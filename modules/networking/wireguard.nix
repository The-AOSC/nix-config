{
  self,
  lib,
  ...
}: {
  lib.wireguard = {
    wireguardNetworkType = lib.types.submodule ({config, ...}: let
      inherit (config) networkId;
    in {
      options = {
        networkId = lib.mkOption {
          type = lib.types.ints.u16;
          description = "Unique id of wireguard network";
        };
        peers = lib.mkOption {
          type = lib.types.submodule {
            freeformType = lib.types.attrsOf (lib.types.submodule ({
              config,
              name,
              ...
            }: {
              options = {
                allowedIPs = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = lib.map (hostname: "${self.lib.wireguard.makeAddress networkId hostname}/128") (config.extraHostnames ++ [name]);
                  defaultText = "IPs generated based on <name> and modules.wireguard.peers.<name>.extraHostnames content"; # TODO: fix path
                  description = "IPs behind this peer.";
                };
                endpoint = lib.mkOption {
                  type = lib.types.nullOr lib.types.str;
                  default = null;
                  description = "IP or hostname, and a port number separated by colon.";
                };
                publicKey = lib.mkOption {
                  type = lib.types.str;
                  default = lib.readFile (../../credentials + "/wireguard-${name}.pub");
                  defaultText = "Contents of corresponding file in ${../../credentials}";
                  description = "The base64 public key of the peer.";
                };
                extraHostnames = lib.mkOption {
                  type = lib.types.listOf lib.types.str;
                  default = [];
                  description = "Extra hostnames of this peer.";
                };
                listenPort = lib.mkOption {
                  type = lib.types.nullOr lib.types.port;
                  default = let
                    match = lib.strings.match "^.+:([0-9]+)$" config.endpoint;
                  in
                    if match == null
                    then null
                    else lib.toInt (lib.elemAt match 0);
                  defaultText = "generated based on peers.<name>.endpoint";
                  description = "Wireguard listen port";
                };
              };
            }));
          };
          description = "Peers linked to wireguard interface";
        };
      };
    });
    makeAddress = network: hostname: "fd07:a05c:8f76:${lib.toLower (lib.toHexString network)}${self.lib.hostnameToIpv6Host hostname}";
  };
  flake.aspects = {aspects, ...}: {
    wireguard = self.lib.aspects.make-namespace {
      instantiate = self': {
        aspect-chain,
        class,
        name,
      }: {
        includes = [
          (self.lib.aspects.forward {
            each = [null];
            fromClass = _: "peers";
            intoClass = _: "nixos";
            intoPath = _: ["modules" "wireguard" name "peers"];
            fromAspect = _: self';
          })
          (self.lib.aspects.forward {
            each = [null];
            fromClass = _: "wireguard";
            intoClass = _: "nixos";
            intoPath = _: ["modules" "wireguard" name];
            fromAspect = _: self';
          })
          self'
        ];
        inherit (self') _ provides;
      };
      perInstance = network: {
        includes = [
          (self.lib.aspects.make-once {
            key = lib.mapAttrsToList (n: v: "${n}-${builtins.toString v}") __curPos;
            fromClasses = ["nixos"];
            fromAspect = {
              includes = [aspects.secrets._.wireguard];
              nixos = {
                options.modules.wireguard = lib.mkOption {
                  type = lib.types.attrsOf self.lib.wireguard.wireguardNetworkType;
                  default = {};
                  description = "Wireguard networks";
                };
                config = {
                  systemd.network.wait-online.enable = false;
                  networking.wireguard = {
                    enable = true;
                    useNetworkd = true;
                  };
                };
              };
            };
          })
        ];
        nixos = {config, ...}: let
          thisPeer = config.modules.wireguard.${network}.peers.${config.networking.hostName};
          peers = lib.removeAttrs config.modules.wireguard.${network}.peers [config.networking.hostName];
        in {
          networking.firewall.allowedUDPPorts = [thisPeer.listenPort];
          networking.wireguard.interfaces."wg${lib.toString config.modules.wireguard.${network}.networkId}" = {
            dynamicEndpointRefreshSeconds = 300;
            ips = lib.map (hostname: "${self.lib.wireguard.makeAddress config.modules.wireguard.${network}.networkId hostname}/64") (thisPeer.extraHostnames ++ [config.networking.hostName]);
            listenPort = thisPeer.listenPort;
            privateKeyFile = config.sops.secrets.wireguard.path;
            peers =
              lib.mapAttrsToList (hostname: peer: {
                inherit (peer) allowedIPs endpoint publicKey;
                name = hostname;
              })
              peers;
          };
          networking.hosts = lib.mkMerge (lib.concatLists (lib.mapAttrsToList (hostname: peer:
            lib.map (hostname: {
              ${self.lib.wireguard.makeAddress 1 hostname} = [hostname];
            }) (peer.extraHostnames ++ [hostname]))
          peers));
        };
      };
    };
  };
}
