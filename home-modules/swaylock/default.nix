{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.swaylock.enable = lib.mkEnableOption "swaylock";
  };
  config = lib.mkIf config.modules.swaylock.enable {
    programs.swaylock = {
      enable = true;
      package = pkgs.swaylock.overrideAttrs (old: {
        patches =
          (old.patches or [])
          ++ [
            ../../patches/swaylock/swaylock-1.8.0-revert-drop-support-for-layer-shell.patch
          ];
        version = "1.8.0";
        src = pkgs.fetchFromGitHub {
          owner = "swaywm";
          repo = "swaylock";
          tag = "v1.8.0";
          hash = "sha256-1+AXxw1gH0SKAxUa0JIhSzMbSmsfmBPCBY5IKaYtldg=";
        };
      });
      settings = {
        show-failed-attempts = true;
        ignore-empty-password = true;
      };
    };
  };
}
