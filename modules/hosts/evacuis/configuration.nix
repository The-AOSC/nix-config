{
  flake.aspects.hosts._.evacuis.nixos = {
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
        patch = ../../../patches/linux/fix-headphones-audio.patch;
      }
    ];
    time.timeZone = "Asia/Yekaterinburg";
    fileSystems."/persist".neededForBoot = true;
    fileSystems."/media".neededForBoot = true;
    users.users.aosc = {
      extraGroups = [
        "dialout"
        "networkmanager"
        "tor"
        "wheel"
        "wireshark"
      ];
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
  };
}
