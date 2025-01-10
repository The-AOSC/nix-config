{config, lib, pkgs, ...}: {
  modules.options.pass = {
    userPackages = [];
    persist.user.data.directories = [
      ".password-store"
    ];
  };
  users.users = config.modules.lib.withModuleUserConfig "pass" (user-name: {
    "${user-name}".packages = let
      git-enabled = config.modules.users."${user-name}".modules.git.enable;
      git-config = config.modules.users."${user-name}".modules.git.config;
      default-pkg = pkgs.pass.withExtensions (subpkgs: with subpkgs; [
        pass-otp
      ]);
    in [
      (lib.mkIf (git-enabled && (git-config != [])) (pkgs.symlinkJoin {
        name = "pass";
        paths = [
          (pkgs.writeShellScriptBin "pass" ''
            export GIT_CONFIG_GLOBAL=${pkgs.writeText "global-git-config" (lib.concatMapStringsSep "\n" lib.generators.toGitINI git-config)}
            exec ${default-pkg}/bin/pass "$@"
          '')
          default-pkg
        ];
      }))
      (lib.mkIf (!(git-enabled && (git-config != []))) default-pkg)
    ];
  });
}
