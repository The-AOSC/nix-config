{
  config,
  pkgs,
  lib,
  ...
}: {
  config = lib.mkIf (config.modules.rofi.enable && config.modules.pass.enable) {
    programs.rofi.pass = {
      enable = true;
      package = pkgs.rofi-pass-wayland.overrideAttrs (old: {
        patches =
          old.patches or []
          ++ [
            # https://github.com/carnager/rofi-pass/pull/238
            (pkgs.fetchpatch2 {
              url = "https://github.com/maffmeier/rofi-pass/commit/dcc9b08c1dc638bb28ee2d410881d51ba6e1421a.patch?full_index=1";
              hash = "sha256-Z63O98eKlN/CO2ycZJtXlhxE71Sl4Y8iGYOX2dZfHWk=";
            })
          ];
      });
      extraConfig = ''
        clip=clipboard
        default_do='copyMenu'
        USERNAME_field='login'
      '';
    };
  };
}
