# icons: https://nerdfonts.ytyng.com/
{
  flake.aspects.desktop._.quickshell.homeManager = {
    config,
    pkgs,
    lib,
    ...
  }: {
    programs.quickshell = {
      enable = true;
      activeConfig = "default";
      configs."default" = pkgs.symlinkJoin {
        name = "quickshell-config";
        paths = [
          "${./config}"
          (pkgs.writeTextDir "theme.js" ''
            var color = JSON.parse("${lib.escape [''"'' ''\''] (lib.toJSON config.lib.catppuccin.colors)}");
            var accentColor = JSON.parse("${lib.escape [''"'' ''\''] (lib.toJSON config.lib.catppuccin.accent)}");
            var font = {
              pixelSize: 13,
              family: "SymbolsNerdFontMono"
            }
          '')
        ];
      };
      systemd.enable = true;
    };
    systemd.user.services.quickshell = {
      Service.RestartSec = 1;
      Unit.X-Restart-Triggers = [
        config.xdg.configFile."quickshell/default".source
      ];
    };
  };
}
