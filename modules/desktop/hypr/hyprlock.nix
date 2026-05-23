{
  flake.aspects.desktop._ = {aspects, ...}: {
    hyprland.includes = [aspects.hyprlock];
    hyprlock = {
      nixos = {
        security.pam.services.hyprlock = {};
      };
      homeManager = {
        config,
        pkgs,
        ...
      }: {
        lib.hyprlock = {
          config-opaque = pkgs.writeText "hyprlock.conf" ''
            source=${config.xdg.configFile."hypr/hyprlock.conf".source}
            background {
              monitor=
              color=$base
            }
          '';
        };
        programs.hyprlock = {
          enable = true;
          settings = {
            general = {
              hide_cursor = true;
              ignore_empty_input = true;
            };
            background = {
              monitor = "";
              color = "rgba(00000000)";
            };
            input-field = {
              monitor = "";
              size = "100, 100";
              fade_on_empty = true;
              hide_input = true;
              outline_thickness = 8;
              outer_color = "$accent";
              inner_color = "$surface0";
              check_color = "$yellow";
              fail_color = "$red";
              placeholder_text = "";
              fail_text = "";
            };
          };
        };
      };
    };
  };
}
