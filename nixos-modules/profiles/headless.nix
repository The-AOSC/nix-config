{
  config,
  lib,
  ...
}: {
  options = {
    profiles.headless = lib.mkEnableOption "headless";
  };
  config = lib.mkIf config.profiles.headless {
    profiles.base = lib.mkDefault true;
    modules.enableNumlock.enable = false;
    modules.theme.enable = false;
  };
}
