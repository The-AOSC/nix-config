{
  config,
  lib,
  ...
}: {
  options = {
    modules.zapret.enable = lib.mkEnableOption "zapret";
  };
  config = lib.mkIf config.modules.zapret.enable {
    services.zapret = {
      enable = true;
      whitelist = [
        "googlevideo.com"
        "youtu.be"
        "youtube.com"
        "ytimg.com"
      ];
      params = [
        # nfqws only
        # to generate run `nix-shell -p zapret --run blockcheck`
      ];
    };
  };
}
