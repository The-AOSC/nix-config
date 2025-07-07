{
  config,
  lib,
  ...
}: let
  cfg = config.modules.netConfig;
in {
  options.modules.netConfig = {
    enable = lib.mkEnableOption "netConfig";
    config = lib.mkOption {
      description = "Hosts network configuration";
    };
    hosts = {
      byHost = lib.mkOption {
        description = "Map from hostName to its networking.hosts option";
        readOnly = true;
        type = with lib.types; attrsOf (attrsOf (listOf str));
      };
      byNetwork = lib.mkOption {
        description = "Map from network to networking.hosts option compatible with hosts in that network";
        readOnly = true;
        type = with lib.types; attrsOf (attrsOf (listOf str));
      };
    };
  };
  config = let
    enable = cfg.enable;
  in {
    modules.netConfig.hosts = {
      byHost = lib.mapAttrs (localhost-name: localhost-config:
        lib.mkMerge ((
            # for every host excluding {host-name} in every reachable {cfg.config.networks}:
            #  {<global-address> = [<host-name>] ++ <extra-domains> ++ <container-names>}
            let
              reachable-networks = lib.filter (network: network ? localhost-name) (lib.attrValues cfg.config.networks);
              reachable-hosts = lib.map (lib.flip lib.removeAttrs [localhost-name]) reachable-networks;
            in
              lib.concatLists (lib.map (lib.mapAttrsToList (host-name: host-config: let
                  names = [host-name] ++ cfg.config.hosts."${host-name}".extra-domains ++ (lib.attrNames cfg.config.hosts."${host-name}".containers);
                in {
                  "${host-config.ipv4}" = names;
                  "${host-config.ipv6}" = names;
                }))
                reachable-hosts)
          )
          ++ (
            # for every container in {localhost-config.containers}:
            #  {<local-address> = <container-name>}
            lib.mapAttrsToList (container-name: container-config: {
              "${container-config.host.ipv4}" = [container-name];
              "${container-config.host.ipv6}" = [container-name];
            })
            localhost-config.containers
          )
          ++ [
            {
              # extra-domains
              "127.0.0.3" = localhost-config.extra-domains;
              "::1" = localhost-config.extra-domains;
            }
          ]))
      cfg.config.hosts;
      byNetwork = lib.mapAttrs (network-name: hosts:
        lib.mkMerge (
          # for every host in {hosts}:
          #  {<global-address> = [<host-name>] ++ <extra-domains> ++ <container-names>}
          lib.mapAttrsToList (host-name: host-config: let
            names = [host-name] ++ cfg.config.hosts."${host-name}".extra-domains ++ (lib.attrNames cfg.config.hosts."${host-name}".containers);
          in {
            "${host-config.ipv4}" = names;
            "${host-config.ipv6}" = names;
          })
          hosts
        ))
      cfg.config.networks;
    };
    networking.hosts = lib.mkIf enable cfg.hosts.byHost."${config.networking.hostName}";
    containers = lib.mkIf enable (
      lib.mapAttrs (container-name: container-config: {
        privateNetwork = true;
        hostAddress = container-config.host.ipv4;
        hostAddress6 = container-config.host.ipv6;
        localAddress = container-config.local.ipv4;
        localAddress6 = container-config.local.ipv6;
      })
      cfg.config.hosts."${config.networking.hostName}".containers
    );
  };
}
