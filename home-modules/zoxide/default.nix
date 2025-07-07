{
  config,
  lib,
  ...
}: {
  options = {
    modules.zoxide.enable = lib.mkEnableOption "zoxide";
  };
  config = lib.mkIf config.modules.zoxide.enable {
    programs.zoxide = {
      enable = true;
      options = [
        "--cmd cd"
      ];
    };
    home.persistence."/persist/home/aosc" = {
      directories = [
        ".local/share/zoxide"
      ];
    };
  };
}
