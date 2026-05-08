{inputs, ...}: {
  flake-file.inputs = {
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
  };
  flake.aspects.base.nixos.nixpkgs.overlays = [
    (final: prev: {
      #inherit (import inputs.nixpkgs-master {inherit (final.stdenv) system;}) endgame-singularity davfs2;
      nh-unwrapped = prev.nh-unwrapped.override (args: {
        rustPlatform =
          args.rustPlatform
          // {
            buildRustPackage = f:
              args.rustPlatform.buildRustPackage (finalAttrs:
                (f finalAttrs)
                // {
                  version = "4.3.0";
                  src = final.fetchFromGitHub {
                    owner = "nix-community";
                    repo = "nh";
                    tag = "v${finalAttrs.version}";
                    hash = "sha256-A3bEBKJlWYqsw41g4RaTwSLUWq8Mw/zz4FpMj4Lua+c=";
                  };
                  cargoHash = "sha256-BLv69rL5L84wNTMiKHbSumFU4jVQqAiI1pS5oNLY9yE=";
                });
          };
      });
    })
  ];
}
