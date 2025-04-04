{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.self.nixosModules.ntp
    inputs.self.nixosModules.persistence
  ];
  fileSystems."/etc/credentials" = {
    device = "/persist/etc/credentials";
    fsType = "none";
    neededForBoot = true;
    options = ["bind"];
  };
  networking = {
    networkmanager.enable = true;
    firewall = {
      enable = true;
      allowPing = true;
    };
  };
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };
  programs.fish.enable = true;
  programs.nano.enable = false;
  programs.neovim.enable = true;
  environment.binsh = "${pkgs.dash}/bin/dash";
  nix.settings = {
    keep-derivations = true;
    keep-going = true;
    keep-outputs = true;
  };
}
