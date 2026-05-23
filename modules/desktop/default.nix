{
  flake.aspects = {aspects, ...}: {
    desktop = {
      includes = [
        aspects.desktop._.hyprland
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
