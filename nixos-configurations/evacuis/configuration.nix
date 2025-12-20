{
  config,
  pkgs,
  lib,
  ...
}: {
  profiles = {
    desktop = true;
    home = true;
  };
  boot.kernelPatches = [
    {
      name = "fix-headphones-audio";
      patch = ../../patches/linux/fix-headphones-audio.patch;
    }
  ];
  time.timeZone = "Asia/Yekaterinburg";
  fileSystems."/persist".neededForBoot = true;
  fileSystems."/media".neededForBoot = true;
  users.users.aosc = {
    openssh.authorizedKeys.keyFiles = [
      ../../credentials/aosc.authorized_keys
    ];
    isNormalUser = true;
    extraGroups = [
      "dialout"
      "networkmanager"
      "tor"
      "wheel"
      "wireshark"
    ];
    shell = pkgs.fish;
  };
  boot.binfmt.emulatedSystems = ["aarch64-linux" "armv7l-linux"];
  system.stateVersion = "25.05";
  environment.persistence."/persist" = {
    directories = [
      "/var/lib/systemd/backlight"
    ];
  };
  services.openssh.ports = [2222];
  modules.amd.enable = true;
  modules.gitlab.enable = true;
  modules.swaylock.enable = true;
  modules.tor.enable = true;
  modules.virt-manager.enable = true;
  modules.kanata.keyboards.default = with config.lib.kanata; {
    defaultLayer = "default";
    extraConfig = ''
      (defvirtualkeys
        vkey-layer-mouse (layer-while-held mouse))
      ${layers.mouse.extra-conf}
    '';
    layers = let
      base =
        mergeLayers layers.homeRowMods.base
        (layers.passthroughKeys ["left" "right" "up" "down"]);
      mode-select = "(layer-while-held mode-select)";
      with-mode-select = mergeLayers {"ralt" = mode-select;};
      with-layout-switch = mergeLayers {
        "lsft" = "f19";
        "rsft" = "f24";
      };
      with-all-mods = lib.flip mergeTapHold (mergeLayers
        (layers.homeRowMods.level-mods "level1" "level2" "level3")
        layers.homeRowMods.mods);
      mouse = layers.mouse.default "mouse-hold";
    in {
      default = layers.withNoDefault (with-all-mods base);
      default-mouse = layers.withNoDefault (with-all-mods (mergeLayers base mouse));
      level1 = layers.withNoDefault (with-all-mods (with-layout-switch layers.homeRowMods.level1));
      level2 = layers.withNoDefault (with-all-mods layers.homeRowMods.level2);
      level3 = layers.withNoDefault (with-mode-select (with-all-mods layers.homeRowMods.level3));
      simple = with-mode-select layers.simple;
      mouse = mouse;
      mouse-hold = layers.mouse.hold;
      mode-select = {
        "caps" = "(multi (on-press release-virtualkey vkey-layer-mouse) (layer-switch default))";
        "s" = "(multi (on-press release-virtualkey vkey-layer-mouse) (layer-switch simple))";
        "m" = ''
          (switch
            ((base-layer default)) (layer-switch default-mouse) break
            ((base-layer simple)) (on-press press-virtualkey vkey-layer-mouse) break)
        '';
      };
    };
    devices = [
      "/dev/input/by-path/platform-i8042-serio-0-event-kbd"
    ];
  };
}
