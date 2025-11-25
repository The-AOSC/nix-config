{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.ssh.enable = lib.mkEnableOption "ssh";
  };
  config = lib.mkIf config.modules.ssh.enable {
    home.packages = with pkgs; [
      ssh-copy-id
    ];
    home.persistence."/persist" = {
      directories = [
        {
          directory = ".ssh";
          mode = "700";
        }
      ];
    };
  };
}
