{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.modules.wiremix;
  tomlFormat = pkgs.formats.toml {};
in {
  options = {
    modules.wiremix = {
      enable = lib.mkEnableOption "wiremix";
      package = lib.mkPackageOption pkgs "wiremix" {};
      settings = lib.mkOption {
        description = "Settings";
        type = lib.types.submodule {
          freeformType = lib.types.attrsOf tomlFormat.type;
          options = {
            keybindings = lib.mkOption {
              type = lib.types.listOf tomlFormat.type;
              description = "Keybindings";
            };
          };
        };
        default = {};
      };
    };
  };
  config = {
    modules.wiremix.settings.keybindings = [
      {
        key.Char = "`";
        action = "Nothing";
      }
      {
        key.Char = "=";
        action = {SetAbsoluteVolume = 0.00;};
      }
      {
        key.Char = "l";
        action = "TabRight";
      }
      {
        key.Char = "L";
        action = "Nothing";
      }
      {
        key.Char = "h";
        action = "TabLeft";
      }
      {
        key.Char = "H";
        action = "Nothing";
      }
      {
        key.Char = " ";
        action = "ActivateDropdown";
      }
    ];
    modules.wiremix.package = pkgs.wiremix.overrideAttrs (old: {
      postInstall = ''
        mkdir -p $out/share
        install -Dm644 ${./wiremix.desktop} $out/share/applications/wiremix.desktop
      '';
    });
    xdg.configFile = lib.mkIf cfg.enable {
      "wiremix/wiremix.toml".source = tomlFormat.generate "wiremix.toml" cfg.settings;
    };
    home.packages = lib.mkIf cfg.enable [
      cfg.package
    ];
  };
}
