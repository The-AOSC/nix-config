{config, lib, pkgs, ...}: let
  module-names-list = lib.mapAttrsToList (module-name: module-options: module-name) config.modules.options;
in {
  options = {
    modules = {
      modules = lib.mapAttrs (module-name: module-options:
      config.modules.options."${module-name}".extraOptions // {
        enable = lib.mkOption {
          default = false;  # enable module ${module-name} globaly
        };
      }) config.modules.options;
      users = let modules-users = {name, ...}: {
        options = let user-name = name;
        in {
          modules = lib.mapAttrs (module-name: module-options:
          config.modules.options."${module-name}".extraUserOptions // {
            enable = lib.mkOption {
              default = false;  # enable module ${module-name} for user ${user-name}
            };
          }) config.modules.options;
        };
      };
      in lib.mkOption {
        type = with lib.types; attrsOf (submodule modules-users);
        default = {};
      };
      options = let modules-options = {name, ...}: {
        options = {
          systemPackages = lib.mkOption{default=[];};
          userPackages = lib.mkOption {
            default = [pkgs."${name}"];
          };
          usersPackages = lib.mkOption{default=[];};
          packages = lib.mkOption{default=[];};
          extraOptions = lib.mkOption{default={};};
          extraUserOptions = lib.mkOption{default={};};
          persist.system.config.files = lib.mkOption{default=[];};
          persist.system.config.directories = lib.mkOption{default=[];};
          persist.system.data.files = lib.mkOption{default=[];};
          persist.system.data.directories = lib.mkOption{default=[];};
          persist.user.config.files = lib.mkOption{default=[];};
          persist.user.config.directories = lib.mkOption{default=[];};
          persist.user.data.files = lib.mkOption{default=[];};
          persist.user.data.directories = lib.mkOption{default=[];};
          persist.users.config.files = lib.mkOption{default=[];};
          persist.users.config.directories = lib.mkOption{default=[];};
          persist.users.data.files = lib.mkOption{default=[];};
          persist.users.data.directories = lib.mkOption{default=[];};
          persist.config.files = lib.mkOption{default=[];};
          persist.config.directories = lib.mkOption{default=[];};
          persist.data.files = lib.mkOption{default=[];};
          persist.data.directories = lib.mkOption{default=[];};
        };
      };
      in lib.mkOption {
        type = with lib.types; attrsOf (submodule modules-options);
        default = {};
      };
      lib = lib.mkOption {
        type = with lib.types; attrsOf anything;
        default = {};
      };
    };
  };
  config = let
    withConfig = cfg: lib.mkMerge (lib.map (module-name: (cfg module-name)) module-names-list);
  in {
    # lib
    ## withModule
    ### if enabled globally
    modules.lib.withModuleSystemConfig = module-name: lib.mkIf config.modules.modules."${module-name}".enable;
    ### if enabled for user
    modules.lib.withModuleUserConfig = module-name: cfg: lib.mkMerge (lib.mapAttrsToList (user-name: user-config:
    lib.mkIf user-config.modules."${module-name}".enable (cfg user-name)
    ) config.modules.users);
    ### if enabled for any user
    modules.lib.withModuleUsersConfig = module-name: lib.mkIf (lib.any lib.id (lib.mapAttrsToList (user-name: user-config:
    user-config.modules."${module-name}".enable
    ) config.modules.users));
    ### if enabled
    modules.lib.withModuleConfig = module-name: lib.mkIf (config.modules.modules."${module-name}".enable ||
    (lib.any lib.id (lib.mapAttrsToList (user-name: user-config:
    user-config.modules."${module-name}".enable
    ) config.modules.users)));
    environment.systemPackages = lib.mkMerge [
      (withConfig (module-name:
      config.modules.lib.withModuleSystemConfig module-name config.modules.options."${module-name}".systemPackages
      ))
      (withConfig (module-name:
      config.modules.lib.withModuleSystemConfig module-name config.modules.options."${module-name}".systemPackages
      ))
      (withConfig (module-name:
      config.modules.lib.withModuleSystemConfig module-name config.modules.options."${module-name}".systemPackages
      ))
    ];
    users.users = withConfig (module-name: config.modules.lib.withModuleUserConfig module-name (user-name: {
      "${user-name}".packages = config.modules.options."${module-name}".userPackages;
    }));
    # persistence
    environment.persistence = withConfig (module-name: {
      "/persist/system" = {
        files = lib.mkMerge [
          (config.modules.lib.withModuleSystemConfig module-name config.modules.options."${module-name}".persist.system.config.files)
          (config.modules.lib.withModuleUsersConfig module-name config.modules.options."${module-name}".persist.users.config.files)
          (config.modules.lib.withModuleConfig module-name config.modules.options."${module-name}".persist.config.files)
        ];
        directories = lib.mkMerge [
          (config.modules.lib.withModuleSystemConfig module-name config.modules.options."${module-name}".persist.system.config.directories)
          (config.modules.lib.withModuleUsersConfig module-name config.modules.options."${module-name}".persist.users.config.directories)
          (config.modules.lib.withModuleConfig module-name config.modules.options."${module-name}".persist.config.directories)
        ];
        users = config.modules.lib.withModuleUserConfig module-name (user-name: {
          "${user-name}" = {
            files = config.modules.options."${module-name}".persist.user.config.files;
            directories = config.modules.options."${module-name}".persist.user.config.directories;
          };
        });
      };
      "/persist/storage" = {
        files = lib.mkMerge [
          (config.modules.lib.withModuleSystemConfig module-name config.modules.options."${module-name}".persist.system.data.files)
          (config.modules.lib.withModuleUsersConfig module-name config.modules.options."${module-name}".persist.users.data.files)
          (config.modules.lib.withModuleConfig module-name config.modules.options."${module-name}".persist.data.files)
        ];
        directories = lib.mkMerge [
          (config.modules.lib.withModuleSystemConfig module-name config.modules.options."${module-name}".persist.system.data.directories)
          (config.modules.lib.withModuleUsersConfig module-name config.modules.options."${module-name}".persist.users.data.directories)
          (config.modules.lib.withModuleConfig module-name config.modules.options."${module-name}".persist.data.directories)
        ];
        users = config.modules.lib.withModuleUserConfig module-name (user-name: {
          "${user-name}" = {
            files = config.modules.options."${module-name}".persist.user.data.files;
            directories = config.modules.options."${module-name}".persist.user.data.directories;
          };
        });
      };
    });
  };
}
