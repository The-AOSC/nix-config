{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.modules.netConfig;
  containerHostnames = lib.attrNames config.containers;
  aliases = cfg.extraHostnames ++ (lib.optionals cfg.advertiseContainers containerHostnames);
in {
  options.modules.netConfig = {
    extraHostnames = lib.mkOption {
      type = with lib.types; listOf str;
      description = "Extra hostnames to advertise using CNAME mDNS records";
      default = [];
    };
    advertiseContainers = lib.mkOption {
      type = lib.types.bool;
      description = "Whether to advertise containers ising CNAME mDNS records";
      default = true;
    };
  };
  config = lib.mkIf cfg.enable {
    services.avahi = {
      enable = true;
      package = pkgs.avahi.overrideAttrs (old: {
        patches =
          old.patches or []
          ++ [
            ../../patches/avahi/0001-Add-capability-to-present-aliases-for-the-host-as-CN.patch
          ];
      });
      nssmdns4 = true;
      nssmdns6 = true;
      publish = {
        enable = true;
        addresses = true;
      };
      extraConfig = lib.mkIf (aliases != []) ''
        [server]
        aliases=${lib.concatStringsSep "," aliases}
      '';
    };
  };
}
