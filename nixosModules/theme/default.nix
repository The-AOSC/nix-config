{
  inputs,
  options,
  config,
  lib,
  ...
}: {
  options = {
    modules.theme = {
      enable = lib.mkEnableOption "theme";
      catppuccin = {
        accent = lib.mkOption {
          inherit (options.catppuccin.accent) type default;
          description = "Catppuccin accent";
        };
        flavor = lib.mkOption {
          inherit (options.catppuccin.flavor) type default;
          description = "Catppuccin flavor";
        };
      };
    };
  };
  imports = [
    inputs.catppuccin.nixosModules.catppuccin
  ];
  config = lib.mkIf config.modules.theme.enable {
    modules.theme.catppuccin = {
      accent = "mauve";
      flavor = "mocha";
    };
    catppuccin = {
      inherit (config.modules.theme.catppuccin) accent flavor;
      enable = true;
    };
  };
}
