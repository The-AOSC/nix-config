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
      terminalStartHold = ''${terminal} --hold -o shell='sleep 99d' --'';
    in {
      enable = true;
      plugins = [
        pkgs.multi-dimensional-workspaces
      ];
      settings = {
        misc = {
          new_window_takes_over_fullscreen = 2; # unfullscreen
          #session_lock_xray = true;
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
          #",                     XF86AudioRaiseVolume,  exec, wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"
          #",                     XF86AudioLowerVolume,  exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          # TODO: don't use pulseaudio's pactl
          ",                     XF86AudioRaiseVolume,  exec, ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ +2.5db"
          ",                     XF86AudioLowerVolume,  exec, ${pkgs.pulseaudio}/bin/pactl set-sink-volume @DEFAULT_SINK@ -2.5db"
          "ALT,                  XF86AudioRaiseVolume,  exec, ${pkgs.pulseaudio}/bin/pactl set-source-volume @DEFAULT_SOURCE@ +2.5db"
          "ALT,                  XF86AudioLowerVolume,  exec, ${pkgs.pulseaudio}/bin/pactl set-source-volume @DEFAULT_SOURCE@ -2.5db"
          ",                     XF86MonBrightnessUp,   exec, brightnessctl -e4 -n2 set 5%+"
          ",                     XF86MonBrightnessDown, exec, brightnessctl -e4 -n2 set 5%-"
        ];
        binde = [
          "SUPER,                s,                     workspace, plugin:mdw:+0:-1"
          "SUPER,                w,                     workspace, plugin:mdw:+0:+1"
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
          #"SUPER,                F7,                    exec, ..." # TODO
          "SUPER,                d,                     exec, wmenu-history"
          # TODO: clipboard
          ",                     XF86PowerOff,          exec, powerctl"
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
          "SUPER,                1,                     workspace, plugin:mdw:1"
          "SUPER,                2,                     workspace, plugin:mdw:2"
          "SUPER,                3,                     workspace, plugin:mdw:3"
          "SUPER,                4,                     workspace, plugin:mdw:4"
          "SUPER,                5,                     workspace, plugin:mdw:5"
          "SUPER SHIFT,          1,                     movetoworkspacesilent, plugin:mdw:1"
          "SUPER SHIFT,          2,                     movetoworkspacesilent, plugin:mdw:2"
          "SUPER SHIFT,          3,                     movetoworkspacesilent, plugin:mdw:3"
          "SUPER SHIFT,          4,                     movetoworkspacesilent, plugin:mdw:4"
          "SUPER SHIFT,          5,                     movetoworkspacesilent, plugin:mdw:5"
          "SUPER SHIFT,          s,                     movetoworkspacesilent, plugin:mdw:+0:-1"
          "SUPER SHIFT,          w,                     movetoworkspacesilent, plugin:mdw:+0:+1"
          "SUPER ALT SHIFT CTRL, Return,                submap, escape"
        ];
        bindm = [
          "SUPER,                m,                     movewindow"
          "SUPER,                mouse:272,             movewindow"
          "SUPER ALT,            m,                     resizewindow"
          "SUPER ALT,            mouse:272,             resizewindow"
        ];
        plugin.mdw = {
          array_sizes = "5:10";
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
          lock_cmd = "swaylock";
          unlock_cmd = "killall -SIGUSR1 .swaylock-wrapper";
        };
      };
    };
    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings.mainBar = {
        position = "top";
        height = 30;
        spacing = 0;
        modules-left = [
          "hyprland/workspaces"
          "hyprland/submap"
        ];
        modules-center = [
          "hyprland/window"
        ];
        modules-right = [
          "wireplumber"
          "network"
          "cpu"
          "memory"
          "temperature"
          "backlight"
          "battery"
          "clock"
          "tray"
        ];
        "hyprland/workspaces" = {
          disable-scroll = true;
          all-outputs = true;
          warp-on-scroll = false;
          /*
          # TODO: does urgent highlight even work?
          format = "{name}: {icon}";
          format-icons = {
            "urgent" = "";
            "active" = "";
            "default" = "";
          };
          */
        };
        wireplumber = {
          format = "{volume}%  {format_source}";
          format-muted = " {format_source}";
          format-source = "{volume}% ";
          format-source-muted = "";
          on-scroll-up = "";
          on-scroll-down = "";
          on-click = "${pkgs.helvum}/bin/helvum";
          tooltip = false;
        };
        network = {
          format-wifi = "{essid} ({signalStrength}%) ";
          format-ethernet = "{ipaddr}/{cidr} ";
          tooltip-format = "{ifname} via {gwaddr}";
          format-linked = "{ifname} (No IP)";
          format-disconnected = "Disconnected ⚠";
        };
        cpu = {
          format = "{usage}% ({load}) ";
          tooltip = false;
        };
        memory = {
          format = "{used:0.1f}G {swapUsed:0.1f}G ";
          tooltip = false;
        };
        temperature = {
          critical-threshold = 90;
          format = "{temperatureC}°C {icon}";
          format-icons = ["" "" "" "" ""];
          tooltip = false;
        };
        backlight = {
          on-scroll-up = "";
          on-scroll-down = "";
          format = "{percent}% {icon}";
          format-icons = ["" "" "" "" "" "" "" "" ""];
          tooltip = false;
        };
        battery = {
          states = {
            #good = 95;
            warning = 30;
            critical = 15;
          };
          tooltip = false;
          format = "{capacity}% {time} {icon}";
          format-full = "{capacity}% {icon}";
          format-charging = "^ {capacity}% {time} {icon}";
          format-discharging = "v {capacity}% {time} {icon}";
          format-time = "{H}:{m}";
          format-icons = ["" "" "" "" ""];
        };
        clock = {
          interval = 1;
          format = "{:%y/%m.%d(%u) %H:%M:%S}";
          tooltip = false;
        };
        tray = {
          spacing = 10;
        };
      };
      style = ''
        * {
          font-family: SymbolsNerdFontMono;
          font-size: 13px;
        }
        window#waybar {
          background-color: transparent;
          color: @text;
        }
        #workspaces,
        #window,
        #wireplumber,
        #network,
        #cpu,
        #memory,
        #temperature,
        #backlight,
        #battery,
        #clock,
        #tray {
          background-color: @surface0;
          padding: 0.5rem 0.5rem;
          margin: 5px 0 0 0;
        }
        #workspaces {
          margin-left: 0.5rem;
          padding: 0;
          background-color: transparent;
        }
        #workspaces button {
          color: @lavender;
          background-color: @surface0;
          border-radius: 1rem;
          padding: 0.4rem;
          margin-left: 0.5rem;
        }
        #workspaces button.active {
          color: @sky;
        }
        #workspaces button:hover {
          color: @sapphire;
          box-shadow: inherit;
          text-shadow: inherit;
        }
        #workspaces button.urgent {
          color: @red;
        }
        #window {
          margin-left: 1rem;
          border-radius: 1rem;
        }
        window#waybar.empty #window {
          /* alternative would be to use "display: none", but it's not supported */
          color: transparent;
          background-color: transparent;
          margin: -999px;
        }
        #wireplumber {
          border-radius: 1rem 0px 0px 1rem;
          margin-left: 1rem;
          color: @maroon;
        }
        #network {
          color: @blue;
        }
        #network.disconnected {
          color: @red;
        }
        #cpu {
          color: @green;
        }
        #memory {
          color: @mauve;
        }
        #temperature {
          color: @peach;
        }
        #temperature.critical {
          color: @red;
        }
        #backlight {
          color: @rosewater;
        }
        #battery {
          color: @yellow
        }
        #battery.charging, #battery.full {
          color: @green;
        }
        #battery.critical:not(.charging) {
          color: @red;
        }
        #clock {
          border-radius: 0px 1rem 1rem 0px;
          margin-right: 1rem;
          color: @sapphire;
        }
        #tray {
          margin-right: 1rem;
          border-radius: 1rem;
        }
      '';
    };
  };
}
/*
# This is an example Hyprland config file.
# Refer to the wiki for more information.
# https://wiki.hypr.land/Configuring/

# Please note not all available settings / options are set here.
# For a full list, see the wiki

# You can split this configuration into multiple files
# Create your files separately and then link them to this file like this:
# source = ~/.config/hypr/myColors.conf


###################
### MY PROGRAMS ###
###################

# See https://wiki.hypr.land/Configuring/Keywords/

# Set programs that you use
$terminal = kitty
$fileManager = dolphin
$menu = wofi --show drun


#################
### AUTOSTART ###
#################

# Autostart necessary processes (like notifications daemons, status bars, etc.)
# Or execute your favorite apps at launch like this:

# exec-once = $terminal
# exec-once = nm-applet &
# exec-once = waybar & hyprpaper & firefox


#####################
### LOOK AND FEEL ###
#####################

# Refer to https://wiki.hypr.land/Configuring/Variables/

# https://wiki.hypr.land/Configuring/Variables/#general
general {
    gaps_in = 5
    gaps_out = 20

    border_size = 2

    # https://wiki.hypr.land/Configuring/Variables/#variable-types for info about colors
    col.active_border = rgba(33ccffee) rgba(00ff99ee) 45deg
    col.inactive_border = rgba(595959aa)

    # Set to true enable resizing windows by clicking and dragging on borders and gaps
    resize_on_border = false

    # Please see https://wiki.hypr.land/Configuring/Tearing/ before you turn this on
    allow_tearing = false

    layout = dwindle
}

# https://wiki.hypr.land/Configuring/Variables/#decoration
decoration {
    rounding = 10
    rounding_power = 2

    # Change transparency of focused and unfocused windows
    active_opacity = 1.0
    inactive_opacity = 1.0

    shadow {
        enabled = true
        range = 4
        render_power = 3
        color = rgba(1a1a1aee)
    }

    # https://wiki.hypr.land/Configuring/Variables/#blur
    blur {
        enabled = true
        size = 3
        passes = 1

        vibrancy = 0.1696
    }
}

# https://wiki.hypr.land/Configuring/Variables/#animations
animations {
    enabled = yes, please :)

    # Default animations, see https://wiki.hypr.land/Configuring/Animations/ for more

    bezier = easeOutQuint,0.23,1,0.32,1
    bezier = easeInOutCubic,0.65,0.05,0.36,1
    bezier = linear,0,0,1,1
    bezier = almostLinear,0.5,0.5,0.75,1.0
    bezier = quick,0.15,0,0.1,1

    animation = global, 1, 10, default
    animation = border, 1, 5.39, easeOutQuint
    animation = windows, 1, 4.79, easeOutQuint
    animation = windowsIn, 1, 4.1, easeOutQuint, popin 87%
    animation = windowsOut, 1, 1.49, linear, popin 87%
    animation = fadeIn, 1, 1.73, almostLinear
    animation = fadeOut, 1, 1.46, almostLinear
    animation = fade, 1, 3.03, quick
    animation = layers, 1, 3.81, easeOutQuint
    animation = layersIn, 1, 4, easeOutQuint, fade
    animation = layersOut, 1, 1.5, linear, fade
    animation = fadeLayersIn, 1, 1.79, almostLinear
    animation = fadeLayersOut, 1, 1.39, almostLinear
    animation = workspaces, 1, 1.94, almostLinear, fade
    animation = workspacesIn, 1, 1.21, almostLinear, fade
    animation = workspacesOut, 1, 1.94, almostLinear, fade
}

# Ref https://wiki.hypr.land/Configuring/Workspace-Rules/
# "Smart gaps" / "No gaps when only"
# uncomment all if you wish to use that.
# workspace = w[tv1], gapsout:0, gapsin:0
# workspace = f[1], gapsout:0, gapsin:0
# windowrule = bordersize 0, floating:0, onworkspace:w[tv1]
# windowrule = rounding 0, floating:0, onworkspace:w[tv1]
# windowrule = bordersize 0, floating:0, onworkspace:f[1]
# windowrule = rounding 0, floating:0, onworkspace:f[1]

# See https://wiki.hypr.land/Configuring/Dwindle-Layout/ for more
dwindle {
    pseudotile = true # Master switch for pseudotiling. Enabling is bound to mainMod + P in the keybinds section below
    preserve_split = true # You probably want this
}

# See https://wiki.hypr.land/Configuring/Master-Layout/ for more
master {
    new_status = master
}

# https://wiki.hypr.land/Configuring/Variables/#misc
misc {
    force_default_wallpaper = -1 # Set to 0 or 1 to disable the anime mascot wallpapers
    disable_hyprland_logo = false # If true disables the random hyprland logo / anime girl background. :(
}


#############
### INPUT ###
#############

# https://wiki.hypr.land/Configuring/Variables/#input
input {
    kb_layout = us
    kb_variant =
    kb_model =
    kb_options =
    kb_rules =

    follow_mouse = 1

    sensitivity = 0 # -1.0 - 1.0, 0 means no modification.

    touchpad {
        natural_scroll = false
    }
}

# https://wiki.hypr.land/Configuring/Variables/#gestures
gestures {
    workspace_swipe = false
}

# Example per-device config
# See https://wiki.hypr.land/Configuring/Keywords/#per-device-input-configs for more
device {
    name = epic-mouse-v1
    sensitivity = -0.5
}


###################
### KEYBINDINGS ###
###################

# See https://wiki.hypr.land/Configuring/Keywords/
$mainMod = SUPER # Sets "Windows" key as main modifier

# Example binds, see https://wiki.hypr.land/Configuring/Binds/ for more
bind = $mainMod, P, pseudo, # dwindle
bind = $mainMod, J, togglesplit, # dwindle

# Move/resize windows with mainMod + LMB/RMB and dragging
bindm = $mainMod, mouse:272, movewindow
bindm = $mainMod, mouse:273, resizewindow

##############################
### WINDOWS AND WORKSPACES ###
##############################

# See https://wiki.hypr.land/Configuring/Window-Rules/ for more
# See https://wiki.hypr.land/Configuring/Workspace-Rules/ for workspace rules

# Example windowrule
# windowrule = float,class:^(kitty)$,title:^(kitty)$

# Ignore maximize requests from apps. You'll probably like this.
windowrule = suppressevent maximize, class:.*

# Fix some dragging issues with XWayland
windowrule = nofocus,class:^$,title:^$,xwayland:1,floating:1,fullscreen:0,pinned:0
*/
