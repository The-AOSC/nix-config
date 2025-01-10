{config, options, lib, pkgs, ...}: {
  modules.options.git = {
    userPackages = [
    ];
    systemPackages = [
      pkgs.git
    ];
    extraUserOptions = {
      config = lib.mkOption {
        default = options.programs.git.config.default;
        type = options.programs.git.config.type;
        description = options.programs.git.config.description;
      };
    };
  };
  users.users = config.modules.lib.withModuleUserConfig "git" (user-name: {
    "${user-name}".packages = let
      git-config = config.modules.users."${user-name}".modules.git.config;
      default-pkg = pkgs.git;
    in [
      (lib.mkIf (git-config != []) (pkgs.symlinkJoin {
        name = "git";
        paths = [
          (pkgs.writeShellScriptBin "git" ''
            export GIT_CONFIG_GLOBAL=${pkgs.writeText "global-git-config" (lib.concatMapStringsSep "\n" lib.generators.toGitINI git-config)}
            exec ${default-pkg}/bin/git "$@"
          '')
          default-pkg
        ];
      }))
      (lib.mkIf (git-config == []) default-pkg)
    ];
  });
}
