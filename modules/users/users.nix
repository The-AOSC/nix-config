{
  inputs,
  lib,
  ...
}: {
  flake.aspects = {aspects, ...}: {
    users = username: let
      forwards = from: [
        (aspects.make-forward {
          each =
            if username != "root"
            then from
            else [];
          fromClass = _: "homeManager";
          intoClass = _: "nixos";
          intoPath = _: ["home-manager" "users" username];
          fromAspect = aspect: aspect;
        })
        (aspects.make-forward {
          each = from;
          fromClass = _: "user";
          intoClass = _: "nixos";
          intoPath = _: ["users" "users" username];
          fromAspect = aspect: aspect;
        })
      ];
      convert-user-aspects = f: {
        includes = let
          from = f aspects.user._.${username} or {};
        in
          [
            ({
              aspect-chain,
              class,
            }: {
              # user and homeManager aspects in user._.<username> should only be included for <username>
              includes =
                if lib.elem class ["user" "homeManager"]
                then []
                else from;
            })
          ]
          ++ (forwards from);
      };
    in {
      includes = [
        ({
          aspect-chain,
          class,
        }: {
          includes =
            [
              # per user config
              (convert-user-aspects (user-aspect: [
                {user.isNormalUser = lib.mkIf (username != "root") true;}
                user-aspect
              ]))
            ]
            # shared config
            ++ (forwards [(lib.head aspect-chain) aspects.base]);
        })
        (aspects.make-once {
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
      ];
      provides = {
        inherit convert-user-aspects;
      };
    };
  };
}
