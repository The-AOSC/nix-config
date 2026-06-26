{
  config,
  lib,
  ...
}: {
  options.lib = lib.mkOption {
    description = "Reusable functions";
    type = lib.types.attrs;
    default = {};
  };
  config = {
    flake.lib = config.lib;
    flake-file.description = "NixOS configuration of The AOSC";
    auto-follow = {
      enable = true;
      simularInputs = [
        [
          {
            original.owner = "nixos";
            original.repo = "flake-compat";
            original.type = "github";
          }
          {
            original.type = "tarball";
            original.url = "https://flakehub.com/f/edolstra/flake-compat/1.tar.gz";
          }
        ]
        [
          {
            original.owner = "nixos";
            original.repo = "nixpkgs";
            original.type = "github";
          }
          {
            original.type = "tarball";
            original.url = "https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz";
          }
        ]
      ];
    };
    systems = ["x86_64-linux"];
  };
}
