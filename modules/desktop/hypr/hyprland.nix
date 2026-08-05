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
      switchWorkspace = func: ''
        function()
          local layer,x,y = hl.plugin.hyprtasking.workspace_id_to_pos((hl.get_active_workspace() or {id=-1}).id)
          hl.plugin.hyprtasking.move_id(hl.plugin.hyprtasking.pos_to_workspace_id(${func}))
        end
      '';
      moveToWorkspace = func: ''
        function()
          local layer,x,y = hl.plugin.hyprtasking.workspace_id_to_pos((hl.get_active_workspace() or {id=-1}).id)
          hl.dispatch(hl.dsp.window.move({workspace=hl.plugin.hyprtasking.pos_to_workspace_id(${func}),follow=false}))
        end
      '';
    in {
      enable = true;
      systemd = {
        enable = true;
        variables = ["--all"];
      };
      configType = "lua";
      plugins = [
        pkgs.hyprtasking
      ];
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
          plugin.hyprtasking = {
            layout = "grid";
            bg_color = (lib.generators.mkLuaInline ''tonumber("0x" .. colors.baseAlpha)'');
            gap_size = 4;
            border_size = 2;
            grid.rows = 5;
            grid.cols = 5;
            grid.layers = 5;
          };
        };
        animation = [
          {
            bezier = "default";
            enabled = true;
            leaf = "workspaces";
            speed = 6.0;
            style = "fade";
          }
        ];
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
            "SUPER + SHIFT + Grave".bind = ''function() hl.plugin.hyprtasking.toggle("cursor") end'';
            "SUPER + 1".bind = switchWorkspace "layer,0,y";
            "SUPER + 2".bind = switchWorkspace "layer,1,y";
            "SUPER + 3".bind = switchWorkspace "layer,2,y";
            "SUPER + 4".bind = switchWorkspace "layer,3,y";
            "SUPER + 5".bind = switchWorkspace "layer,4,y";
            "SUPER + w".bind = ''function() hl.plugin.hyprtasking.move("up") end'';
            "SUPER + s".bind = ''function() hl.plugin.hyprtasking.move("down") end'';
            "SUPER + 6".bind = ''function() hl.plugin.hyprtasking.setlayer(0) end'';
            "SUPER + 7".bind = ''function() hl.plugin.hyprtasking.setlayer(1) end'';
            "SUPER + 8".bind = ''function() hl.plugin.hyprtasking.setlayer(2) end'';
            "SUPER + 9".bind = ''function() hl.plugin.hyprtasking.setlayer(3) end'';
            "SUPER + 0".bind = ''function() hl.plugin.hyprtasking.setlayer(4) end'';
            "SUPER + SHIFT + 1".bind = moveToWorkspace "layer,0,y";
            "SUPER + SHIFT + 2".bind = moveToWorkspace "layer,1,y";
            "SUPER + SHIFT + 3".bind = moveToWorkspace "layer,2,y";
            "SUPER + SHIFT + 4".bind = moveToWorkspace "layer,3,y";
            "SUPER + SHIFT + 5".bind = moveToWorkspace "layer,4,y";
            "SUPER + SHIFT + w".bind = moveToWorkspace "layer,x,math.max(y-1,0)";
            "SUPER + SHIFT + s".bind = moveToWorkspace "layer,x,math.min(y+1,4)";
            "SUPER + SHIFT + 6".bind = moveToWorkspace "0,x,y";
            "SUPER + SHIFT + 7".bind = moveToWorkspace "1,x,y";
            "SUPER + SHIFT + 8".bind = moveToWorkspace "2,x,y";
            "SUPER + SHIFT + 9".bind = moveToWorkspace "3,x,y";
            "SUPER + SHIFT + 0".bind = moveToWorkspace "4,x,y";
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
