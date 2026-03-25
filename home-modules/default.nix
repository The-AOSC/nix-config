{inputs, ...}: {
  imports = builtins.attrValues (builtins.removeAttrs inputs.self.homeModules ["default"]);
}
