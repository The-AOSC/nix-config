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
    catppuccin = {
      inherit (config.modules.theme.catppuccin) accent flavor;
      enable = true;
      cursors.enable = false;
      librewolf.profiles = lib.mkIf config.modules.librewolf.enable {
        default = {};
        private.accent = "blue";
        tor.accent = "red";
      };
    };
    home.pointerCursor = {
      name = "phinger-cursors-dark";
      package = pkgs.phinger-cursors;
      gtk.enable = true;
      size = 24;
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
    };
    qt = {
      enable = true;
      platformTheme.name = "kvantum";
      style.name = "kvantum";
    };
  };
}
