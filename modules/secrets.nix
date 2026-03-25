{
  inputs,
  lib,
  ...
}: {
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
    users = username: {
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
