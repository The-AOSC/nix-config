{
  flake.aspects = {aspects, ...}: {
    desktop = {
      includes = [
        aspects.desktop._.hyprland
        aspects.desktop._.quickshell
      ];
      nixos = {
        programs.uwsm = {
          enable = true;
          waylandCompositors = {};
        };
        environment.pathsToLink = [
          "/share/applications"
          "/share/xdg-desktop-portal"
        ];
      };
    };
  };
}
