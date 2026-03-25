{inputs, ...}: {
  imports = builtins.attrValues (builtins.removeAttrs inputs.self.nixosModules ["default"]);
  config = {
    nixpkgs.overlays = [
      inputs.self.overlays.default
    ];
  };
}
