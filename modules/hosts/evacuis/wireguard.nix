{
  flake.aspects = {aspects, ...}: {
    wireguard._.vpn-home.peers.evacuis = {
      endpoint = "evacuis.local:51820";
      extraHostnames = [
        "evacuis-webdav"
        "gitlab"
      ];
    };
    hosts._.evacuis.includes = [
      (aspects.wireguard "vpn-home")
    ];
  };
}
