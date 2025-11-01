{
  inputs,
  config,
  lib,
  ...
}: {
  imports = [
    inputs.nix-index-database.nixosModules.nix-index
  ];
  options = {
    modules.nix-index.enable = lib.mkEnableOption "nix-index";
  };
  config = lib.mkIf config.modules.nix-index.enable {
    programs.nix-index-database.comma.enable = true;
  };
}
