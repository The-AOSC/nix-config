{...}: {
  system = "x86_64-linux";
  nixos-modules = [
    ../configuration.nix
    ../inst.nix
    ../work.nix
    ../gitlab.nix
    ../persistence.nix
  ];
  home-modules = [
    ../home.nix
    ../work-home.nix
  ];
  username = "vladimir";
}
