inputs @ {...}: {
  overlays = [
    inputs.self.overlays.wtf
    inputs.self.overlays.downgrade-wine-mono
  ];
  nixos-modules = [
    inputs.flake-programs-sqlite.nixosModules.programs-sqlite
    inputs.impermanence.nixosModules.impermanence
    inputs.nixvirt.nixosModules.default
    inputs.self.nixosModules.amd
    inputs.self.nixosModules.desktop
    inputs.self.nixosModules.gitlab
    inputs.self.nixosModules.netConfig
    inputs.self.nixosModules.sshd
    inputs.self.nixosModules.swaylock
    inputs.self.nixosModules.tor
    inputs.self.nixosModules.virt-manager
    inputs.self.nixosModules.zapret
    ./configuration.nix
    ./hardware-configuration.nix
    ./unfree.nix
  ];
  home = {
    "aosc" = {
      modules = [
        inputs.impermanence.homeManagerModules.impermanence
        inputs.self.homeManagerModules.desktop
        inputs.self.homeManagerModules.rldebugfs
        inputs.self.homeManagerModules.swaylock
        inputs.self.homeManagerModules.tor
        inputs.self.homeManagerModules.tor-browser
        ./home.nix
        ./unfree-fonts.nix
      ];
    };
  };
}
