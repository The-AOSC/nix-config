{config, pkgs, ...}: {
  modules.options.audio = {
    userPackages = [
      pkgs.helvum
      pkgs.pulseaudio  # pactl
    ];
    persist.user.data.directories = [
      ".local/state/wireplumber"
    ];
  };
  services.pipewire = config.modules.lib.withModuleUsersConfig "audio" {
    enable = true;
    pulse.enable = true;
  };
  # TODO: is this necessary?
  users.users = config.modules.lib.withModuleUserConfig "audio" (user-name: {
    "${user-name}".extraGroups = [
      "audio"
    ];
  });
}
