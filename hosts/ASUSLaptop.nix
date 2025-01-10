{...}: {
  system = "x86_64-linux";
  nixos-modules = [
    ../nixos-modules/configuration.nix
    ../nixos-modules/gitlab.nix
    ../nixos-modules/hardware-configuration.nix
    ../nixos-modules/inst.nix
    ../nixos-modules/persistence.nix
    ../nixos-modules/remote-config.nix
    ../nixos-modules/work.nix
    ../nixos-modules/zapret.nix
  ];
  home-modules = [
    ../home-modules/home.nix
    ../home-modules/mpv.nix
    ../home-modules/wezterm.nix
    ../home-modules/work-home.nix
  ];
  username = "vladimir";
}
