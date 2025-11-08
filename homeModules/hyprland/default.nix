{
  config,
  pkgs,
  lib,
  ...
}: let
  debug = true;
in {
  options = {
    modules.hyprland.enable = lib.mkEnableOption "hyprland";
  };
  config = lib.mkIf config.modules.hyprland.enable {
    programs.fish.loginShellInit = ''
      if uwsm check may-start -g 0
        export UWSM_SILENT_START=2 # skip warning about graphical.target with 5 second wait
        exec uwsm start -g 0 ${config.wayland.windowManager.hyprland.finalPackage}/bin/Hyprland
      end
    '';
    services.hyprpolkitagent.enable = true;
    wayland.systemd.target = "hyprland-session.target";
    wayland.windowManager.hyprland = let
      terminal = "${config.programs.kitty.package}/bin/kitty --single-instance";
      terminalStart = "${terminal} --";
      terminalStartHold = ''${terminal} --single-instance=no --hold -o shell='sleep 99d' --'';
    in {
      enable = true;
      plugins = [
        pkgs.multi-dimensional-workspaces
      ];
      settings = {
        misc = {
          new_window_takes_over_fullscreen = 2; # unfullscreen
          session_lock_xray = true;
          force_default_wallpaper = 0;
        };
        input = {
          kb_layout = "custom"; # see xkb module
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
          force_split = 2; # bottom/right
        };
        /*
        bind flags:
        l - allow on lockscreen
        e - repeat
        r - trigger on release
        m - mouse specific binds
        */
        bindl = [
          ",                     XF86AudioMute,         exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          "SHIFT,                XF86AudioMute,         exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 100%"
          "SHIFT,                XF86AudioMute,         exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ 0"
          "ALT,                  XF86AudioMute,         exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
          "SHIFT ALT,            XF86AudioMute,         exec, wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 100%"
          "SHIFT ALT,            XF86AudioMute,         exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0"
          "ALT CTRL,             XF86AudioMute,         exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0"
        ];
        bindlr = [
          "ALT CTRL,             XF86AudioMute,         exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1"
        ];
        bindle = [
          ",                     XF86AudioRaiseVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2.5db+"
          ",                     XF86AudioLowerVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 2.5db-"
          "ALT,                  XF86AudioRaiseVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 2.5db+"
          "ALT,                  XF86AudioLowerVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SOURCE@ 2.5db-"
          ",                     XF86MonBrightnessUp,   exec, brightnessctl -e4 -n2 set 5%+"
          ",                     XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
        ];
        binde = [
          "SUPER,                s,                     plugin:mdw:focusworkspaceoncurrentmonitor, plugin:mdw:+0:-1"
          "SUPER,                w,                     plugin:mdw:focusworkspaceoncurrentmonitor, plugin:mdw:+0:+1"
        ];
        bind = [
          "SUPER,                Return,                exec, ${terminalStart} fish"
          "SUPER SHIFT,          Escape,                exec, ${terminalStart} htop"
          "SUPER ALT,            n,                     exec, ${terminalStartHold} sh -c 'sleep 0.1; fastfetch'"
          "SUPER,                F2,                    exec, librewolf --profile ~/.librewolf/default"
          "SUPER SHIFT,          F2,                    exec, librewolf --profile ~/.librewolf/private"
          "SUPER ALT,            F2,                    exec, librewolf --profile ~/.librewolf/tor"
          "SUPER,                F4,                    exec, ${terminalStart} rlcl"
          "SUPER,                F6,                    exec, ${terminalStart} sh -c 'sleep 0.1; while true; do nmtui; done'"
          "SUPER,                r,                     exec, rofi -show drun"
          ",                     XF86PowerOff,          exec, rofi -show power -no-show-icons"
          "SUPER,                c,                     exec, sh -c 'wl-paste -n|wl-copy'"
          "SUPER ALT,            c,                     exec, sh -c 'wl-paste -n -p|wl-copy'"
          "SUPER SHIFT,          q,                     killactive"
          "SUPER SHIFT,          Space,                 togglefloating"
          "SUPER,                f,                     fullscreen, 0"
          "SUPER,                h,                     movefocus, l"
          "SUPER,                j,                     movefocus, d"
          "SUPER,                k,                     movefocus, u"
          "SUPER,                l,                     movefocus, r"
          "SUPER SHIFT,          h,                     movewindow, l"
          "SUPER SHIFT,          j,                     movewindow, d"
          "SUPER SHIFT,          k,                     movewindow, u"
          "SUPER SHIFT,          l,                     movewindow, r"
          "SUPER ALT,            h,                     swapwindow, l"
          "SUPER ALT,            j,                     swapwindow, d"
          "SUPER ALT,            k,                     swapwindow, u"
          "SUPER ALT,            l,                     swapwindow, r"
          "SUPER,                1,                     plugin:mdw:focusworkspaceoncurrentmonitor, plugin:mdw:1"
          "SUPER,                2,                     plugin:mdw:focusworkspaceoncurrentmonitor, plugin:mdw:2"
          "SUPER,                3,                     plugin:mdw:focusworkspaceoncurrentmonitor, plugin:mdw:3"
          "SUPER,                4,                     plugin:mdw:focusworkspaceoncurrentmonitor, plugin:mdw:4"
          "SUPER,                5,                     plugin:mdw:focusworkspaceoncurrentmonitor, plugin:mdw:5"
          "SUPER,                6,                     plugin:mdw:focusworkspaceoncurrentmonitor, plugin:mdw:+0:+0:1"
          "SUPER,                7,                     plugin:mdw:focusworkspaceoncurrentmonitor, plugin:mdw:+0:+0:2"
          "SUPER,                8,                     plugin:mdw:focusworkspaceoncurrentmonitor, plugin:mdw:+0:+0:3"
          "SUPER,                9,                     plugin:mdw:focusworkspaceoncurrentmonitor, plugin:mdw:+0:+0:4"
          "SUPER,                0,                     plugin:mdw:focusworkspaceoncurrentmonitor, plugin:mdw:+0:+0:5"
          "SUPER SHIFT,          1,                     movetoworkspacesilent, plugin:mdw:1"
          "SUPER SHIFT,          2,                     movetoworkspacesilent, plugin:mdw:2"
          "SUPER SHIFT,          3,                     movetoworkspacesilent, plugin:mdw:3"
          "SUPER SHIFT,          4,                     movetoworkspacesilent, plugin:mdw:4"
          "SUPER SHIFT,          5,                     movetoworkspacesilent, plugin:mdw:5"
          "SUPER SHIFT,          s,                     movetoworkspacesilent, plugin:mdw:+0:-1"
          "SUPER SHIFT,          w,                     movetoworkspacesilent, plugin:mdw:+0:+1"
          "SUPER SHIFT,          6,                     movetoworkspacesilent, plugin:mdw:+0:+0:1"
          "SUPER SHIFT,          7,                     movetoworkspacesilent, plugin:mdw:+0:+0:2"
          "SUPER SHIFT,          8,                     movetoworkspacesilent, plugin:mdw:+0:+0:3"
          "SUPER SHIFT,          9,                     movetoworkspacesilent, plugin:mdw:+0:+0:4"
          "SUPER SHIFT,          0,                     movetoworkspacesilent, plugin:mdw:+0:+0:5"
          "SUPER ALT SHIFT CTRL, Return,                submap, escape"
        ];
        bindm = [
          "SUPER,                m,                     movewindow"
          "SUPER,                mouse:272,             movewindow"
          "SUPER ALT,            m,                     resizewindow"
          "SUPER ALT,            mouse:272,             resizewindow"
        ];
        plugin.mdw = {
          array_sizes = "5:5:5";
          animations = "slide left|slide right:slide bottom|slide top:fade";
        };
        debug.disable_logs = !debug;
      };
      submaps = {
        escape.settings = {
          bind = ["SUPER ALT SHIFT CTRL, Escape, submap, reset"];
        };
      };
      systemd = {
        enable = true;
        variables = ["--all"];
      };
    };
    xdg.configFile."hypr/hyprland.conf".text = lib.mkIf (!debug) (lib.mkMerge [
      # https://wiki.hypr.land/Hypr-Ecosystem/hyprlang/#escaping-errors
      (lib.mkBefore ''
        # hyprlang noerror true
      '')
      (lib.mkAfter ''
        # hyprlang noerror false
      '')
    ]);
    services.hypridle = {
      enable = true;
      settings = {
        general = {
          before_sleep_cmd = "loginctl lock-session";
          lock_cmd = "${config.programs.hyprlock.package}/bin/hyprlock -c ${config.lib.hyprlock.config-opaque}";
          unlock_cmd = "killall -SIGUSR1 hyprlock";
          inhibit_sleep = 3; # wait for session lock
        };
      };
    };
  };
}
