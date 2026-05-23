{
  flake.aspects.desktop._.hyprland.homeManager = {config, ...}: {
    programs.fish.loginShellInit = ''
      if tty|not grep pts -q; and uwsm check may-start -g 0
        export UWSM_SILENT_START=2 # skip warning about graphical.target with 5 second wait
        exec uwsm start -D Hyprland -g 0 ${config.wayland.windowManager.hyprland.finalPackage}/bin/start-hyprland
      end
    '';
  };
}
