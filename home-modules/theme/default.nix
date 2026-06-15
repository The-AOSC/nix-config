{
  inputs,
  osConfig,
  options,
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.theme = {
      enable = lib.mkEnableOption "theme";
      catppuccin = {
        accent = lib.mkOption {
          inherit (options.catppuccin.accent) type;
          description = "Catppuccin accent";
          default = osConfig.modules.theme.catppuccin.accent;
        };
        flavor = lib.mkOption {
          inherit (options.catppuccin.flavor) type;
          description = "Catppuccin flavor";
          default = osConfig.modules.theme.catppuccin.flavor;
        };
      };
    };
  };
  imports = [
    inputs.catppuccin.homeModules.catppuccin
    ./librewolf.nix
  ];
  config = lib.mkIf config.modules.theme.enable {
    lib.catppuccin = rec {
      palette = lib.importJSON "${pkgs.catppuccin}/palette/palette.json";
      colors = palette.${config.catppuccin.flavor}.colors;
      accent = colors.${config.catppuccin.accent};
    };
    catppuccin = {
      inherit (config.modules.theme.catppuccin) accent flavor;
      enable = true;
      autoEnable = true;
      cursors.enable = false;
      librewolf.profiles = lib.mkIf config.modules.librewolf.enable {
        default = {};
        private.accent = "blue";
        tor.accent = "red";
      };
      hyprlock.useDefaultConfig = false;
    };
    home.pointerCursor = {
      name = "phinger-cursors-dark";
      package = pkgs.phinger-cursors;
      gtk.enable = true;
      size = 24;
    };
    home.sessionVariables = {
      HYPRCURSOR_SIZE = config.home.pointerCursor.size;
      HYPRCURSOR_THEME = config.home.pointerCursor.name;
    };
    gtk = {
      enable = true;
      theme = {
        name = "catppuccin-${config.catppuccin.flavor}-${config.catppuccin.accent}-standard";
        package = pkgs.catppuccin-gtk.override {
          accents = [config.catppuccin.accent];
          size = "standard";
          variant = config.catppuccin.flavor;
        };
      };
      gtk3 = {
        extraConfig.gtk-application-prefer-dark-theme = config.catppuccin.flavor != "latte";
      };
      gtk4.theme = config.gtk.theme;
    };
    qt = {
      enable = true;
      platformTheme.name = "kvantum";
      style.name = "kvantum";
    };
    wayland.windowManager.hyprland.settings = {
      config = {
        general = {
          #"col.inactive_border" = lib.generators.mkLuaInline "colors.surface0";
          # this is the only way to apply gradient to unfocused window (see https://github.com/hyprwm/Hyprland/discussions/14030)
          "col.inactive_border" = {
            colors = [
              (lib.generators.mkLuaInline "colors.surface0")
              (lib.generators.mkLuaInline "colors.blue")
              (lib.generators.mkLuaInline "colors.blue")
            ];
            angle = 45;
          };
          "col.active_border" = lib.generators.mkLuaInline "colors.accent";
        };
        misc."col.splash" = lib.generators.mkLuaInline "colors.text";
      };
      window_rule = let
        mkColors = tokens: lib.generators.mkLuaInline (lib.concatStringsSep ''.." "..'' tokens);
      in [
        {
          match.float = false;
          match.pin = false;
          border_color = mkColors [
            "colors.accent"
            "colors.surface0"
          ];
        }
        {
          match.float = true;
          match.pin = false;
          match.focus = true;
          border_color = mkColors [
            "colors.accent"
            "colors.blue"
            ''"45deg"''
            # ignored (set in col.inactive_border)
            "colors.surface0"
            "colors.blue"
            "colors.blue"
            ''"45deg"''
          ];
        }
        {
          match.float = true;
          match.pin = true;
          match.focus = true;
          border_color = mkColors [
            "colors.accent"
            "colors.red"
            ''"45deg"''
            # ignored (replaced with solid color)
            "colors.surface0"
            "colors.red"
            ''"45deg"''
          ];
        }
        {
          match.float = true;
          match.pin = true;
          match.focus = false;
          border_color = mkColors [
            "colors.red"
            "colors.red"
          ];
        }
      ];
    };
  };
}
