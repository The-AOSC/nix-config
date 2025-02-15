inputs@{...}: {
  system = "x86_64-linux";
  nixos-modules = [
    inputs.impermanence.nixosModules.impermanence
    ./hardware-configuration.nix
    {
      networking = {
        hostName = "evacuis";
        networkmanager.enable = true;
      };
      boot.loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
      time.timeZone = "Asia/Yekaterinburg";
      users.mutableUsers = false;
      users.users.root.hashedPasswordFile = "/etc/credentials/root.hashedpassword";
      fileSystems."/persist".neededForBoot = true;
      fileSystems."/etc/credentials".neededForBoot = true;
      environment.persistence."/persist" = {
        enable = true;
        directories = [
          "/var/lib/nixos"
          "/var/log/journal"
        ];
        files = [
          "/etc/machine-id"
        ];
      };
      system.stateVersion = "25.05";
    }
  ];
  home = {
    /*
    "AOSC" = {
      modules = [
        inputs.impermanence.homeManagerModules.impermanence
        ({osConfig, ...}: {
          home.stateVersion = osConfig.system.stateVersion;
        })
      ];
    };
    */
  };
}
