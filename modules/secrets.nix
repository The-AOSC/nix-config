{
  inputs,
  lib,
  ...
}: {
  perSystem = {pkgs, ...}: {
    packages = {
      generate-wireguard-key = pkgs.writeShellApplication {
        name = "generate-wireguard-key";
        runtimeInputs = with pkgs; [
          sops
          wireguard-tools
        ];
        text = ''
          set -e
          if [ $# -eq 0 ]; then
            printf 'Usage: %s [hostname]\n' "$0" >&2
            printf 'Generate wireguard key pair for host\n' >&2
            exit 1
          fi
          priv="$(wg genkey)"
          printf 'key: %s' "$priv" | sops --config ./modules/.sops.yaml encrypt --filename-override "modules/secrets/wireguard-$1.yaml" --output "modules/secrets/wireguard-$1.yaml"
          wg pubkey <<< "$priv" > "./credentials/wireguard-$1.pub"
        '';
      };
    };
  };
  flake-file.inputs.sops-nix.url = "github:Mic92/sops-nix";
  flake.aspects = {aspects, ...}: {
    secrets.nixos = {
      imports = [
        inputs.sops-nix.nixosModules.sops
      ];
    };
    secrets.provides.networkSecret = secret: {
      nixos.sops.secrets.${secret} = {
        format = "dotenv";
        key = "";
        sopsFile = ./secrets + "/${secret}.env";
      };
    };
    secrets.provides.gitlab = {owner}: {
      nixos.sops.secrets = lib.listToAttrs (lib.map (lib.flip lib.nameValuePair {
          sopsFile = ./secrets/gitlab-secrets.yaml;
          inherit owner;
        }) [
          "active-record-deterministic-key"
          "active-record-primary-key"
          "active-record-salt"
          "database-password"
          "db"
          "initial-root-password"
          "jws"
          "otp"
          "secret"
        ]);
    };
    secrets.provides.wireguard.nixos = {config, ...}: {
      sops.secrets.wireguard = {
        sopsFile = ./secrets + "/wireguard-${config.networking.hostName}.yaml";
        mode = "0640";
        owner = "root";
        group = "systemd-network";
        key = "key";
      };
    };
    users.perInstance = username: {
      provides.sops-password = {
        nixos = {config, ...}: {
          sops.secrets."${username}-password" = {
            sopsFile = ./secrets + "/${username}-password.yaml";
            key = "hash";
            neededForUsers = true;
          };
          users.users.${username}.hashedPasswordFile = config.sops.secrets."${username}-password".path;
        };
      };
    };
  };
}
