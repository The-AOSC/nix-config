{
  config,
  pkgs,
  lib,
  ...
}: {
  boot.kernelPatches = [
    {
      name = "fix-headphones-audio";
      patch = ../../patches/linux/fix-headphones-audio.patch;
    }
  ];
  netConfig.config = builtins.fromJSON (builtins.readFile ../../netConfig.json);
  time.timeZone = "Asia/Yekaterinburg";
  users.users.aosc = {
    hashedPasswordFile = "/etc/credentials/aosc.hashedpassword";
    openssh.authorizedKeys.keyFiles = [
      ../../credentials/aosc.authorized_keys
    ];
    isNormalUser = true;
    extraGroups = [
      "dialout"
      "networkmanager"
      #"video"
      "wheel"
      "wireshark"
    ];
    shell = pkgs.fish;
  };
  boot.binfmt.emulatedSystems = ["aarch64-linux" "armv7l-linux"];
  system.stateVersion = "25.05";
  environment.persistence."/persist" = {
    directories = [
      "/var/lib/samba"
      "/var/lib/systemd/backlight"
    ];
  };
  services.samba = {
    enable = true;
    openFirewall = true;
    nmbd.enable = true;
    settings = {
      global = {
        security = "user";
        "unix extensions" = true;
        "allow insecure wide links" = true;
        "wide links" = false;
        "acl allow execute always" = true;
      };
      "aosc" = {
        comment = "aosc";
        path = "${config.users.users.aosc.home}/smb";
        "valid users" = "aosc";
        public = false;
        writable = true;
        "read only" = false;
        printable = false;
        "create mask" = "0755";
      };
      "aosc-ro" = {
        comment = "aosc readonly";
        path = "${config.users.users.aosc.home}/smbro";
        "valid users" = "aosc";
        public = false;
        writable = false;
        "read only" = true;
        printable = false;
        "create mask" = "0755";
        "wide links" = true;
      };
    };
  };
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
  services.autofs = {
    enable = true;
    autoMaster = let
      cyclone = pkgs.writeText "autofs-cyclone" ''
        /home/aosc/cyclone-win -fstype=smb3,defaults,username=user,password=1,domainauto,uid=aosc,gid=users,actimeo=0 ://192.168.0.180/Users/user/Desktop/cyclone
      '';
    in ''
      /- file:${cyclone} browse --timeout 60
    '';
  };
  services.openssh.ports = [7132];
  kanata.keyboards.default = with config.lib.kanata; {
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
      default = layers.withNoDefault (with-all-mods (with-layout-switch base));
      default-mouse = layers.withNoDefault (with-all-mods (with-layout-switch (mergeLayers base mouse)));
      level1 = layers.withNoDefault (with-all-mods (with-layout-switch layers.homeRowMods.level1));
      level2 = layers.withNoDefault (with-all-mods (with-layout-switch layers.homeRowMods.level2));
      level3 = layers.withNoDefault (with-all-mods (with-mode-select (with-layout-switch layers.homeRowMods.level3)));
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
