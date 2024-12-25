{config, lib, ...}: {
  modules.options.allow-unfree = {
    userPackages = [];
    extraOptions = {
      allowUnfree = lib.mkOption {
        type = with lib.types; listOf str;
        default = [];
        description = ''
          List of unfree package names, allowed for installation
        '';
      };
    };
  };
  nixpkgs.config = config.modules.lib.withModuleSystemConfig "allow-unfree" {
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) config.modules.modules.allow-unfree.allowUnfree;
  };
}
