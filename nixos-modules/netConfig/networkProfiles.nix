{
  options,
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.modules.netConfig;
in {
  options.modules.netConfig = {
    networks = lib.mkOption {
      description = "Network configurations";
      type = with lib.types;
        attrsOf (submodule ({name, ...}: {
          freeformType = (pkgs.formats.ini {}).type;
          options = {
            secrets = lib.mkOption {
              description = "Sops files with secrets required for this network";
              type = attrsOf path;
              default = {};
            };
            connection.id = lib.mkOption {
              inherit ((options.networking.networkmanager.ensureProfiles.profiles.type.nestedTypes.elemType.getSubOptions [(throw "[unused argument]")]).connection.id) description type;
              default = name;
            };
          };
        }));
      default = {};
    };
  };
  config = lib.mkIf cfg.enable {
    sops.secrets = lib.mkMerge (lib.mapAttrsToList (_: network:
      lib.mapAttrs (_: path: {
        format = "dotenv";
        key = "";
        sopsFile = path;
      })
      network.secrets)
    cfg.networks);
    networking.networkmanager.ensureProfiles = {
      environmentFiles = lib.concatLists (lib.mapAttrsToList (_: network: lib.mapAttrsToList (name: _: config.sops.secrets."${name}".path) network.secrets) cfg.networks);
      profiles = lib.mapAttrs (_: network: removeAttrs network ["secrets"]) cfg.networks;
    };
  };
}
