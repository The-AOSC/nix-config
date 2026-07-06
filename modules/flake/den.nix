{
  inputs,
  den,
  ...
}: {
  flake-file.inputs.den.url = "github:denful/den";
  imports = [inputs.den.flakeModule];
  den.default.includes = [
    den.batteries.hostname
    {
      nixos = {lib, ...}: {
        options.permittedInsecurePackages.packages = lib.mkOption {internal = true;};
        options.unfree.packages = lib.mkOption {internal = true;};
      };
    }
  ];
}
