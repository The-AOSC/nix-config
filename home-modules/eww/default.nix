{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.modules.eww;
  eww-cmd = "${config.programs.eww.package}/bin/eww --no-daemonize -c ${cfg.configDir}";
in {
  imports = [
    ./backlight.nix
    ./battery.nix
    ./cpu.nix
    ./hyprland.nix
    ./network.nix
    ./wireplumber.nix
  ];
  options = {
    modules.eww = {
      enable = lib.mkEnableOption "eww";
      systemd = {
        enable = lib.mkEnableOption "Eww systemd integration";
        target = lib.mkOption {
          type = lib.types.str;
          default = config.wayland.systemd.target;
          defaultText = lib.literalExpression "config.wayland.systemd.target";
          description = ''
            The systemd target that will automatically start the Eww service.
          '';
        };
      };
      style = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = ''
          Configuration to write into eww.scss
        '';
      };
      config = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = ''
          Configuration to write into eww.yuck
        '';
      };
      configDir = lib.mkOption {
        type = lib.types.path;
        readOnly = true;
        internal = true;
        description = ''
          Eww configuration directory
        '';
        default = pkgs.linkFarm "eww-config" [
          {
            name = "eww.scss";
            path = pkgs.writeText "eww.scss" cfg.style;
          }
          {
            name = "eww.yuck";
            path = pkgs.writeText "eww.yuck" cfg.config;
          }
        ];
      };
    };
  };
  config = lib.mkIf cfg.enable {
    modules.eww.style = builtins.readFile ./eww.scss;
    modules.eww.config = builtins.readFile ./eww.yuck;
    programs.eww = {
      enable = true;
      package = pkgs.eww.overrideAttrs (old: {
        patches =
          old.patches or []
          ++ [
            # https://github.com/elkowar/eww/pull/1097
            ../../patches/eww/systray-add-visible-empty-property-for-systray-widget.patch
          ];
      });
    };
    systemd.user.services = {
      eww = {
        Unit = {
          Description = "ElKowars wacky widgets";
          Documentation = "https://elkowar.github.io/eww/";
          PartOf = [
            cfg.systemd.target
            "tray.target"
          ];
          After = [cfg.systemd.target];
          ConditionEnvironment = "WAYLAND_DISPLAY";
        };
        Service = {
          ExecStart = "${eww-cmd} daemon";
          Restart = "on-failure";
        };
        Install.WantedBy = [
          cfg.systemd.target
          "tray.target"
        ];
      };
      eww-hyprland = lib.mkIf (config.wayland.windowManager.hyprland.enable && config.wayland.windowManager.hyprland.systemd.enable) {
        Unit = {
          Description = "Eww's integration with hyprland";
          PartOf = [
            "eww.service"
            "hyprland-session.target"
          ];
          After = [
            "eww.service"
            "hyprland-session.target"
          ];
          ConditionEnvironment = [
            "HYPRLAND_INSTANCE_SIGNATURE"
            "WAYLAND_DISPLAY"
          ];
        };
        Service = {
          ExecStart = pkgs.writeShellScript "eww-hyprland" ''
            set -e
            handle() {
              case $1 in
                "monitoraddedv2>>"*)
                  echo add:
                  echo $1
                  #${eww-cmd} open bar --screen $id --id "bar$id"
                  ;;
                "monitorremovedv2>>"*)
                  echo remove:
                  echo $1
                  #${eww-cmd} close "bar$id"
                  ;;
              esac
            }
            {
              sleep 1
              for id in $(${config.wayland.windowManager.hyprland.finalPackage}/bin/hyprctl -j monitors | jq ".[].id"); do
                ${eww-cmd} open bar --screen $id --id "bar$id" || true
              done
            } &
            ${pkgs.socat}/bin/socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
          '';
          Restart = "always";
        };
        Install.WantedBy = [
          cfg.systemd.target
        ];
      };
    };
  };
}
