{...}: {
  system = "x86_64-linux";
  nixos-modules = [
    ../configuration.nix
    ../gitlab.nix
    ../inst.nix
    ../persistence.nix
    ../remote-config.nix
    ../work.nix
    ../zapret.nix
  ];
  home-modules = [
    ../home.nix
    ../work-home.nix
    ../mpv.nix
  ];
  username = "vladimir";
}
