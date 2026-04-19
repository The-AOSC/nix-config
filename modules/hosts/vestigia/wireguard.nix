{
  flake.aspects = {aspects, ...}: {
    wireguard._.vpn-home.peers.vestigia = {
      endpoint = "vestigia.local:51820";
    };
    hosts._.vestigia.includes = [
      (aspects.wireguard "vpn-home")
    ];
  };
}
