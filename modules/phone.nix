{
  self,
  lib,
  ...
}: let
  wireguardPublicKey = "y30NxrLOz6LOcrRcvrND6r6dRfKa3cdUdNcdfaOqbkA=";
  hostname = "phone";
  stubPrivateKey = "AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  makeWireguardConfig = pkgs: networkName: let
    network =
      (lib.evalModules {
        modules = [
          {
            options.wireguardNetwork = lib.mkOption {
              type = self.lib.wireguard.wireguardNetworkType;
            };
          }
          (self.lib.aspects.aspects-lib.resolve "phoneWireguard" [] {
            includes = [
              (self.lib.aspects.forward {
                each = [null];
                fromClass = _: "peers";
                intoClass = _: "phoneWireguard";
                intoPath = _: ["wireguardNetwork" "peers"];
                fromAspect = _: self.aspects.wireguard networkName;
              })
              (self.lib.aspects.forward {
                each = [null];
                fromClass = _: "wireguard";
                intoClass = _: "phoneWireguard";
                intoPath = _: ["wireguardNetwork"];
                fromAspect = _: self.aspects.wireguard networkName;
              })
            ];
          })
        ];
      }).config.wireguardNetwork;
    thisPeer = network.peers.${hostname};
    peers = lib.removeAttrs network.peers [hostname];
  in
    (pkgs.formats.ini {
      listToValue = lib.join ", ";
      mkSectionName = name:
        lib.escape ["[" "]"] (
          if lib.hasPrefix "Peer-" name
          then "Peer"
          else name
        );
    }).generate "wireguard.conf" ({
        Interface = {
          Address = lib.map (hostname: "${self.lib.wireguard.makeAddress network.networkId hostname}/64") (thisPeer.extraHostnames ++ [hostname]);
          PrivateKey = stubPrivateKey;
        };
      }
      // (lib.mapAttrs' (hostname: peer:
        lib.nameValuePair "Peer-${hostname}" (lib.filterAttrs (_: value: value != null) {
          AllowedIPs = peer.allowedIPs;
          Endpoint = peer.endpoint;
          PublicKey = peer.publicKey;
        }))
      peers));
in {
  flake.aspects.wireguard._.vpn-home = {
    peers.${hostname} = {
      publicKey = wireguardPublicKey;
    };
    nixos = {pkgs, ...}: {
      system.checks = [
        (pkgs.runCommand "ensure-custom-wireguard-key-was-generated" {
            buildInputs = [pkgs.wireguard-tools];
          } ''
            [ "$(wg pubkey <<< "${stubPrivateKey}")" != "${wireguardPublicKey}" ] && touch $out
          '')
      ];
    };
  };
  perSystem = {pkgs, ...}: {
    packages.phone-config = let
      networks = ["vpn-home"];
    in
      pkgs.runCommand "phone-config" {
      } ''
        ${lib.concatMapStringsSep "\n" (name: "cp ${makeWireguardConfig pkgs name} ${name}.conf") networks}
        mkdir $out
        ${lib.getExe pkgs.zip} $out/wireguard.zip ${lib.escapeShellArgs (lib.map (name: "${name}.conf") networks)}
      '';
  };
}
