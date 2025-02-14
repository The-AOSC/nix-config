inputs@{...}: {
  system = "x86_64-linux";
  nixos-modules = [
    inputs.impermanence.nixosModules.impermanence
    inputs.nixvirt.nixosModules.default
    ../nixos-modules/configuration.nix
    ../nixos-modules/gitlab.nix
    ../nixos-modules/hardware-configuration.nix
    ../nixos-modules/inst.nix
    ../nixos-modules/persistence.nix
    ../nixos-modules/remote-config.nix
    ../nixos-modules/tor
    ../nixos-modules/virt-manager
    ../nixos-modules/work.nix
    ../nixos-modules/zapret.nix
  ];
  home = {
    "vladimir" = {
      modules = [
        inputs.impermanence.homeManagerModules.impermanence
        ../home-modules/cava
        ../home-modules/endgame-singularity
        ../home-modules/fish
        ../home-modules/git
        ../home-modules/gpg
        ../home-modules/home.nix
        ../home-modules/htop
        ../home-modules/mpv.nix
        ../home-modules/neovim
        ../home-modules/pass
        ../home-modules/tmux
        ../home-modules/tor-browser
        ../home-modules/unp
        ../home-modules/wezterm.nix
        ../home-modules/work-home.nix
      ];
    };
  };
}
