inputs@{...}: {
  system = "x86_64-linux";
  nixos-modules = [
    ({pkgs-24-05, ...}: {
      nixpkgs.overlays = [
        (final: prev: (with pkgs-24-05; {
          neovim-unwrapped = neovim-unwrapped;
          wrapNeovim = wrapNeovim;
        }))
      ];
    })
    inputs.impermanence.nixosModules.impermanence
    inputs.nixvirt.nixosModules.default
    ../nixos-modules/configuration.nix
    ../nixos-modules/gitlab.nix
    ../nixos-modules/hardware-configuration.nix
    ../nixos-modules/inst.nix
    ../nixos-modules/persistence.nix
    ../nixos-modules/remote-config.nix
    ../nixos-modules/virt-manager
    ../nixos-modules/work.nix
    ../nixos-modules/zapret.nix
  ];
  home = {
    "vladimir" = {
      modules = [
        inputs.impermanence.homeManagerModules.impermanence
        ../home-modules/home.nix
        ../home-modules/mpv.nix
        ../home-modules/wezterm.nix
        ../home-modules/work-home.nix
      ];
    };
  };
}
