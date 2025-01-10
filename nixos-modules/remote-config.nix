{...}: {
  environment.etc."nixos/flake.nix" = {
    text = ''
      {
        inputs = {
          nix-config.url = "git+http://ASUSLaptop/The-AOSC/nix-config.git";
        };
        outputs = {nix-config, ...}: nix-config.outputs;
      }
    '';
    mode = "0444";
  };
  fileSystems."/etc/nixos" = {
    device = "/persist/system/etc/nixos";
    fsType = "none";
    options = ["bind"];
    neededForBoot = true;
  };
}
