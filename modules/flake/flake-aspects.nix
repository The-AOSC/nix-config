{
  inputs,
  lib,
  ...
}: {
  flake-file.inputs.flake-aspects.url = "github:vic/flake-aspects";
  imports = [
    inputs.flake-aspects.flakeModule
  ];
  lib.aspects = rec {
    aspects-lib = inputs.flake-aspects.lib lib;
    inherit (aspects-lib) forward;
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
    make-namespace = args: {config, ...}: {
      imports = [args];
      options = {
        perInstance = lib.mkOption {
          type = lib.types.functionTo (aspects-lib.types.aspectSubmodule {});
          default = _: {};
        };
        instantiate = lib.mkOption {
          type = lib.mkOptionType {
            name = "function";
            check = lib.isFunction;
          };
          default = self: {
            aspect-chain,
            class,
            name,
          }:
            self;
        };
      };
      config = {
        perInstance = name: config._.${name} or {};
        __functor = self: name: let
          instantiateRecursive = aspect: {
            includes = [
              ({
                aspect-chain,
                class,
              }:
                config.instantiate aspect {
                  inherit aspect-chain class name;
                })
            ];
            provides = lib.mapAttrs (_: instantiateRecursive) aspect.provides;
            _ = lib.mapAttrs (_: instantiateRecursive) aspect._;
          };
        in
          instantiateRecursive (self.perInstance name);
      };
    };
  };
}
