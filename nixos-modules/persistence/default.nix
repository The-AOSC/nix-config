{
  inputs,
  config,
  lib,
  ...
}: {
  imports = [
    inputs.impermanence.nixosModules.impermanence
  ];
  options = {
    modules.persistence.enable = lib.mkEnableOption "persistence";
  };
  config = lib.mkIf config.modules.persistence.enable {
    environment.persistence."/persist" = {
      enable = true;
      directories = [
        "/etc/NetworkManager/system-connections"
        "/var/lib/nixos"
        "/var/log/journal"
      ];
      files = [
        "/etc/machine-id"
      ];
    };
  };
}
