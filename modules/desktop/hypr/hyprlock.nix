{
  flake.aspects.desktop._ = {aspects, ...}: {
    hyprland.includes = [aspects.hyprlock];
    hyprlock = {
      nixos = {
        security.pam.services.hyprlock = {
          config,
          lib,
          ...
        }: {
          # hyprlock starts pam conversation before key is inserted (927e09fb7dac85df8e21c64989b65bcd3383d67e)
          rules.auth = {
            rootskipu2f.order = config.rules.auth.unix.order + 1;
            u2f.order = config.rules.auth.unix.order + 2;
            unix.control = lib.mkForce "required";
            rootskipu2f.control = lib.mkForce "sufficient";
          };
          u2fAuthControl = "sufficient";
        };
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
