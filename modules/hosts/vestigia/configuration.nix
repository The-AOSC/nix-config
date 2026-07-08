{
  flake.aspects.hosts._.vestigia.nixos = {
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
    time.timeZone = "Asia/Yekaterinburg";
    environment.systemPackages = with pkgs; [
      brightnessctl
    ];
    fileSystems."/persist".neededForBoot = true;
    system.stateVersion = "25.11";
    modules.tor.enable = true;
  };
}
