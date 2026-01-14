{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.modules.neovim;
in {
  options = {
    modules.neovim.enable = lib.mkEnableOption "neovim";
    modules.neovim.package = lib.mkOption {
      type = lib.types.package;
      description = "Neovim package to use";
      default = pkgs.nixvim-configured;
    };
  };
  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];
    home.sessionVariables = {
      MANPAGER = "${lib.getExe cfg.package} +Man!";
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
    home.persistence."/persist" = {
      directories = [
        ".local/state/nvim"
      ];
    };
  };
}
