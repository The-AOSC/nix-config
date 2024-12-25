{config, ...}: {
  imports = [
    ({config, ...}: {
      users.users.root = config.modules.lib.withModuleSystemConfig "users" {
        # mkpasswd -m SHA-512 | tr -d '\n' > root.hashedpassword
        hashedPasswordFile = "/etc/credentials/root.hashedpassword";
      };
    })
  ];
  modules.options.users = {
    userPackages = [];
  };
  nix.settings.allowed-users = config.modules.lib.withModuleUsersConfig "users" ["@wheel"];
  users.mutableUsers = config.modules.lib.withModuleConfig "users" false;
  environment.sessionVariables = config.modules.lib.withModuleUsersConfig "users" {
    XDG_CACHE_HOME = "$HOME/.cache";
    XDG_CONFIG_HOME = "$HOME/.config";
    XDG_DATA_HOME = "$HOME/.local/share";
    XDG_STATE_HOME = "$HOME/.local/state";
  };
  users.users = config.modules.lib.withModuleUserConfig "users" (user-name: {
    "${user-name}" = {
      hashedPasswordFile = "/etc/credentials/${user-name}.hashedpassword";
      isNormalUser = true;
    };
  });
}
