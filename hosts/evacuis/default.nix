inputs@{...}: {
  system = "x86_64-linux";
  nixos-modules = [
    inputs.flake-programs-sqlite.nixosModules.programs-sqlite
    inputs.impermanence.nixosModules.impermanence
    inputs.nixvirt.nixosModules.default
    ./configuration.nix
    ./hardware-configuration.nix
    ./unfree.nix
    ../../nixos-modules/desktop.nix
    ../../nixos-modules/gitlab
    ../../nixos-modules/sshd
    ../../nixos-modules/swaylock
    ../../nixos-modules/tor
    ../../nixos-modules/virt-manager
    ../../nixos-modules/zapret
  ];
  home = {
    "aosc" = {
      modules = [
        inputs.impermanence.homeManagerModules.impermanence
        ./home.nix
        #./unfree-fonts.nix
        ../../home-modules/desktop.nix
        ../../home-modules/rldebugfs
        ../../home-modules/swaylock
        ../../home-modules/tor
        ../../home-modules/tor-browser
      ];
    };
  };
}
