{
  config,
  lib,
  ...
}: {
  options = {
    modules.ssh.enable = lib.mkEnableOption "ssh";
  };
  config = lib.mkIf config.modules.ssh.enable {
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
