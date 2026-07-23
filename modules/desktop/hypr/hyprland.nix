{
  flake.aspects.desktop._.hyprland.homeManager = {
    config,
    pkgs,
    lib,
    ...
  }: {
    services.hyprpolkitagent.enable = true;
    wayland.systemd.target = "hyprland-session.target";
    wayland.windowManager.hyprland = let
      terminal = "${lib.getExe config.programs.kitty.package} --single-instance";
      terminalStart = "${terminal} --";
      terminalStartHold = "${terminal} --single-instance=no --hold -o shell='sleep 99d' --";
      switchWorkspace = func: style: ''
        function()
          local id = (hl.get_active_workspace() or {id=1}).id-1
          local new = ${func}
          if (id ~= new) then
            hl.animation({
              bezier = "default",
              enabled = true,
              leaf = "workspaces",
              speed = 8.0,
              style = "${style}",
            })
            hl.dispatch(hl.dsp.focus({workspace=new+1,on_current_monitor=true}))
          end
        end
      '';
      moveToWorkspace = func: ''
        function()
          local id = (hl.get_active_workspace() or {id=1}).id-1
          local new = ${func}
          if (id ~= new) then
            hl.dispatch(hl.dsp.window.move({workspace=new+1,follow=false}))
          end
        end
      '';
    in {
      enable = true;
      systemd = {
        enable = true;
        variables = ["--all"];
      };
      configType = "lua";
      settings = {
        config = {
          misc = {
            on_focus_under_fullscreen = 2; # unfullscreen
            session_lock_xray = true;
            force_default_wallpaper = 0;
          };
          input = {
            kb_layout = "us, ru";
            kb_options = "custom:layout_switch"; # see xkb module
            numlock_by_default = true;
            repeat_rate = 50;
            repeat_delay = 500;
            touchpad = {
              disable_while_typing = false;
              natural_scroll = true;
            };
          };
          binds = {
            workspace_center_on = 1; # center the cursor on last active window
            focus_preferred_method = 1; # prefer longest shared edge
            disable_keybind_grabbing = true;
          };
          cursor = {
            inactive_timeout = 10;
            warp_on_change_workspace = 1;
          };
          ecosystem = {
            no_update_news = true;
            no_donation_nag = true;
          };
          dwindle = {
            preserve_split = true;
            force_split = 2; # bottom/right
          };
        };
        monitor = lib.singleton {
          output = "";
          mode = "highres";
          position = "auto";
          scale = 1;
        };
        window_rule = [
          {
            match.class = ".*";
            suppress_event = "maximize";
          }
          {
            match.class = "org.gnupg.pinentry-qt";
            pin = true;
          }
          {
            match.title = "Hyprland Polkit Agent";
            pin = true;
          }
        ];
        bind = lib.concatLists (
          lib.mapAttrsToList (hotkey: value:
            lib.map ({bind, ...} @ opts: {
              _args = [
                hotkey
                (lib.generators.mkLuaInline bind)
                (lib.removeAttrs opts ["bind"])
              ];
            }) (lib.toList value)) {
            # speakers
            "XF86AudioMute" = {
              bind = ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")'';
              locked = true;
            };
            "SHIFT + XF86AudioMute" = {
              bind = ''
                function()
                  hl.dispatch(hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 100%"))
                  hl.dispatch(hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ 0"))
                end
              '';
              locked = true;
            };
            "XF86AudioRaiseVolume" = {
              bind = ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2.5db+")'';
              locked = true;
              repeating = true;
            };
            "XF86AudioLowerVolume" = {
              bind = ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 2.5db-")'';
              locked = true;
              repeating = true;
            };
            # mic
            "ALT + XF86AudioMute" = {
              bind = ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")'';
              locked = true;
            };
            "SHIFT + ALT + XF86AudioMute" = {
              bind = ''
                function()
                  hl.dispatch(hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 100%"))
                  hl.dispatch(hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0"))
                end
              '';
              locked = true;
            };
            "ALT + XF86AudioRaiseVolume" = {
              bind = ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 2.5db+")'';
              locked = true;
              repeating = true;
            };
            "ALT + XF86AudioLowerVolume" = {
              bind = ''hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 2.5db-")'';
              locked = true;
              repeating = true;
            };
            # mic push to speak
            "ALT + CTRL + XF86AudioMute" = [
              {
                bind = ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0")'';
                locked = true;
              }
              {
                bind = ''hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1")'';
                locked = true;
                release = true;
              }
            ];
            # brightness
            "XF86MonBrightnessUp" = {
              bind = ''hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+")'';
              locked = true;
              repeating = true;
            };
            "XF86MonBrightnessDown" = {
              bind = ''hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-")'';
              locked = true;
              repeating = true;
            };
            # mouse
            "SUPER + m" = {
              bind = ''hl.dsp.window.drag()'';
              mouse = true;
            };
            "SUPER + mouse:272" = {
              bind = ''hl.dsp.window.drag()'';
              mouse = true;
            };
            "SUPER + ALT + m" = {
              bind = ''hl.dsp.window.resize()'';
              mouse = true;
            };
            "SUPER + ALT + mouse:272" = {
              bind = ''hl.dsp.window.resize()'';
              mouse = true;
            };
            # workspaces
            "SUPER + 1".bind = switchWorkspace "id//5*5+0" "slide";
            "SUPER + 2".bind = switchWorkspace "id//5*5+1" "slide";
            "SUPER + 3".bind = switchWorkspace "id//5*5+2" "slide";
            "SUPER + 4".bind = switchWorkspace "id//5*5+3" "slide";
            "SUPER + 5".bind = switchWorkspace "id//5*5+4" "slide";
            "SUPER + s".bind = switchWorkspace "id//25*25+math.max((id//5)%5-1, 0)*5+id%5" "slidevert -100%";
            "SUPER + w".bind = switchWorkspace "id//25*25+math.min((id//5)%5+1, 4)*5+id%5" "slidevert -100%";
            "SUPER + 6".bind = switchWorkspace "25*0+id%25" "fade";
            "SUPER + 7".bind = switchWorkspace "25*1+id%25" "fade";
            "SUPER + 8".bind = switchWorkspace "25*2+id%25" "fade";
            "SUPER + 9".bind = switchWorkspace "25*3+id%25" "fade";
            "SUPER + 0".bind = switchWorkspace "25*4+id%25" "fade";
            "SUPER + SHIFT + 1".bind = moveToWorkspace "id//5*5+0";
            "SUPER + SHIFT + 2".bind = moveToWorkspace "id//5*5+1";
            "SUPER + SHIFT + 3".bind = moveToWorkspace "id//5*5+2";
            "SUPER + SHIFT + 4".bind = moveToWorkspace "id//5*5+3";
            "SUPER + SHIFT + 5".bind = moveToWorkspace "id//5*5+4";
            "SUPER + SHIFT + s".bind = moveToWorkspace "id//25*25+math.max((id//5)%5-1, 0)*5+id%5";
            "SUPER + SHIFT + w".bind = moveToWorkspace "id//25*25+math.min((id//5)%5+1, 4)*5+id%5";
            "SUPER + SHIFT + 6".bind = moveToWorkspace "25*0+id%25";
            "SUPER + SHIFT + 7".bind = moveToWorkspace "25*1+id%25";
            "SUPER + SHIFT + 8".bind = moveToWorkspace "25*2+id%25";
            "SUPER + SHIFT + 9".bind = moveToWorkspace "25*3+id%25";
            "SUPER + SHIFT + 0".bind = moveToWorkspace "25*4+id%25";
            # windows
            "SUPER + h".bind = ''hl.dsp.focus({direction="left"})'';
            "SUPER + j".bind = ''hl.dsp.focus({direction="down"})'';
            "SUPER + k".bind = ''hl.dsp.focus({direction="up"})'';
            "SUPER + l".bind = ''hl.dsp.focus({direction="right"})'';
            "SUPER + SHIFT + h".bind = ''hl.dsp.window.move({direction="left"})'';
            "SUPER + SHIFT + j".bind = ''hl.dsp.window.move({direction="down"})'';
            "SUPER + SHIFT + k".bind = ''hl.dsp.window.move({direction="up"})'';
            "SUPER + SHIFT + l".bind = ''hl.dsp.window.move({direction="right"})'';
            "SUPER + ALT + h".bind = ''hl.dsp.window.swap({direction="left"})'';
            "SUPER + ALT + j".bind = ''hl.dsp.window.swap({direction="down"})'';
            "SUPER + ALT + k".bind = ''hl.dsp.window.swap({direction="up"})'';
            "SUPER + ALT + l".bind = ''hl.dsp.window.swap({direction="right"})'';
            "SUPER + ALT + SHIFT + j".bind = ''hl.dsp.layout("rotatesplit 90")'';
            "SUPER + ALT + SHIFT + k".bind = ''hl.dsp.layout("rotatesplit -90")'';
            "SUPER + f".bind = ''hl.dsp.window.fullscreen()'';
            "SUPER + SHIFT + q".bind = ''hl.dsp.window.close()'';
            "SUPER + Space".bind = ''
              function()
                if ((hl.get_active_window() or {}).floating) then
                  hl.dispatch(hl.dsp.focus({window="tiled"}))
                else
                  hl.dispatch(hl.dsp.focus({window="floating"}))
                end
              end
            '';
            "SUPER + SHIFT + Space".bind = ''hl.dsp.window.float()'';
            "SUPER + SHIFT + ALT + Space".bind = ''hl.dsp.window.pin()'';
            # launch
            "SUPER + Return".bind = ''hl.dsp.exec_cmd("${terminalStart} fish")'';
            "SUPER + SHIFT + Escape".bind = ''hl.dsp.exec_cmd("${terminalStart} htop")'';
            "SUPER + ALT + n".bind = ''hl.dsp.exec_cmd("${terminalStartHold} sh -c 'sleep 0.1; fastfetch'")'';
            "SUPER + F2".bind = ''hl.dsp.exec_cmd("librewolf --profile ~/.librewolf/default")'';
            "SUPER + SHIFT + F2".bind = ''hl.dsp.exec_cmd("librewolf --profile ~/.librewolf/private")'';
            "SUPER + ALT + F2".bind = ''hl.dsp.exec_cmd("librewolf --profile ~/.librewolf/tor")'';
            "SUPER + F4".bind = ''hl.dsp.exec_cmd("${terminalStart} rlcl")'';
            "SUPER + F6".bind = ''hl.dsp.exec_cmd("${terminalStart} sh -c sleep 0.1; while true; do nmtui; done")'';
            "SUPER + r".bind = ''hl.dsp.exec_cmd("rofi -show drun")'';
            "SUPER + p".bind = ''hl.dsp.exec_cmd("rofi-pass --last-used")'';
            "XF86PowerOff".bind = ''hl.dsp.exec_cmd("rofi -show power -no-show-icons")'';
            # misc
            "SUPER + c".bind = ''hl.dsp.exec_cmd("wl-paste -n | wl-copy")'';
            "SUPER + ALT + c".bind = ''hl.dsp.exec_cmd("wl-paste -n -p | wl-copy")'';
            "Print".bind = ''hl.dsp.exec_cmd("${lib.getExe pkgs.grim} -c")'';
            "CTRL + Print".bind = let
              hyprctl = lib.getExe' config.wayland.windowManager.hyprland.package "hyprctl";
              query = ''[.[]|select(.floating|not)]|sort_by(.focusHistoryID)|first|"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"'';
            in ''hl.dsp.exec_cmd(${lib.generators.toLua {} ''${lib.getExe pkgs.grim} -c -g "$(${hyprctl} clients -j | ${lib.getExe pkgs.jq} -r '${query}')"''})'';
            "CTRL + SHIFT + Print".bind = ''hl.dsp.exec_cmd("${lib.getExe pkgs.grim} -c -g \"$(${lib.getExe pkgs.slurp})\"")'';
            "SUPER + ALT + SHIFT + CTRL + Return".bind = ''hl.dsp.submap("escape")'';
          }
        );
      };
      submaps.escape.settings.bind = [
        {
          _args = [
            "SUPER + ALT + SHIFT + CTRL + Escape"
            (lib.generators.mkLuaInline ''hl.dsp.submap("reset")'')
          ];
        }
      ];
    };
  };
}
