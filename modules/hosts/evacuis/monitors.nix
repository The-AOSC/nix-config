{
  flake.aspects.hosts._.evacuis.homeManager.wayland.windowManager.hyprland.settings.monitor = [
    {
      output = "eDP-1";
      mode = "1920x1080@60";
      scale = 1;
    }
    {
      output = "Virtual-1";
      mode = "prefered";
      position = "auto";
      scale = 1;
    }
  ];
}
