{
  inputs,
  config,
  lib,
  ...
}: {
  flake.aspects = {aspects, ...}: {
    users = let
      forwards = from: username: [
        (config.lib.aspects.forward {
          each = lib.optionals (username != "root") from;
          fromClass = _: "homeManager";
          intoClass = _: "nixos";
          intoPath = _: ["home-manager" "users" username];
          fromAspect = aspect: aspect;
        })
        (config.lib.aspects.forward {
          each = from;
          fromClass = _: "user";
          intoClass = _: "nixos";
          intoPath = _: ["users" "users" username];
          fromAspect = aspect: aspect;
        })
      ];
    in
      config.lib.aspects.make-namespace {
        instantiate = self: {
          aspect-chain,
          class,
          name,
        }: {
          includes = lib.optionals (!(lib.elem class ["user" "homeManager"])) (
            (forwards [self] name) ++ [self]
          );
          inherit (self) _ provides;
        };
        perInstance = username: {
          user.isNormalUser = lib.mkIf (username != "root") true;
          includes = [
            (inputs.self.lib.aspects.make-once {
              key = lib.mapAttrsToList (n: v: "${n}-${builtins.toString v}") __curPos;
              fromClasses = ["nixos"];
              fromAspect.nixos = {
                imports = [
                  inputs.home-manager.nixosModules.home-manager
                ];
                home-manager = {
                  extraSpecialArgs = {inherit inputs;};
                  useGlobalPkgs = true;
                  useUserPackages = true;
                };
              };
            })
            ({
              aspect-chain,
              class,
            }: {
              includes = forwards [aspects.base (lib.head aspect-chain)] username;
            })
          ];
        };
      };
  };
}
