{
  config,
  pkgs,
  lib,
  ...
}: {
  profiles = {
    headless = false;
    home = true;
    server = true;
  };
  systemd.services."getty@tty1" = {
    overrideStrategy = "asDropin";
    serviceConfig.ExecStart = lib.mkBefore [""]; # override default from `getty@.service`
    script = ''
      exec ${lib.getExe pkgs.asciiquarium-transparent} -t
    '';
  };
  time.timeZone = "Asia/Yekaterinburg";
  environment.systemPackages = with pkgs; [
    brightnessctl
  ];
  fileSystems."/persist".neededForBoot = true;
  services.tor.client.socksListenAddress.addr = lib.mkForce "0.0.0.0";
  networking.firewall.allowedTCPPorts = [9150]; # tor proxy
  system.stateVersion = "25.11";
  modules.tor.enable = true;
  modules.kanata.enable = true;
  modules.kanata.keyboards.default = with config.lib.kanata; {
    defaultLayer = "default";
    layers = let
      with-all-mods = lib.flip mergeTapHold (mergeLayers
        (layers.homeRowMods.level-mods "level1" "level2" "level3")
        layers.homeRowMods.mods);
    in {
      default = layers.withNoDefault (with-all-mods layers.homeRowMods.base);
      level1 = layers.withNoDefault (with-all-mods layers.homeRowMods.level1);
      level2 = layers.withNoDefault (with-all-mods layers.homeRowMods.level2);
      level3 = layers.withNoDefault (with-all-mods layers.homeRowMods.level3);
    };
  };
}
