{
  inputs,
  lib,
  ...
}: {
  flake-file.inputs.flake-aspects.url = "github:vic/flake-aspects";
  imports = [
    inputs.flake-aspects.flakeModule
  ];
  flake.aspects = let
    aspects-lib = inputs.flake-aspects.lib lib;
  in {
    make-forward = {
      each,
      fromClass,
      intoClass,
      intoPath,
      fromAspect,
    } @ args:
      aspects-lib.forward args;
    make-once = {
      key,
      fromClasses,
      fromAspect,
    }: let
      include = class: {
        ${class} = {
          key = "${builtins.toString key}-${class}";
          imports = [(aspects-lib.resolve class [] fromAspect)];
        };
      };
    in {
      includes = map include fromClasses;
    };
  };
}
