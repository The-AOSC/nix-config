{
  flake.aspects.desktop._.hyprland.homeManager = {config, ...}: {
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
