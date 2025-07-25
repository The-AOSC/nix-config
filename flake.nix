{
  description = "NixOS configuration of The AOSC";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    impermanence = {
      url = "github:nix-community/impermanence/home-manager-v2";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    # https://flakehub.com/flake/AshleyYakeley/NixVirt
    nixvirt.url = "https://flakehub.com/f/AshleyYakeley/NixVirt/*.tar.gz";
    nixvirt.inputs.nixpkgs.follows = "nixpkgs";
    flake-programs-sqlite.url = "github:wamserma/flake-programs-sqlite";
    flake-programs-sqlite.inputs.nixpkgs.follows = "nixpkgs";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-parts.url = "github:hercules-ci/flake-parts";
    nix-mineral = {
      url = "github:cynicsketch/nix-mineral";
      flake = false;
    };
    files.url = "github:mightyiam/files";
  };
  outputs = inputs @ {
    flake-parts,
    self,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} (
      top @ {...}: {
        imports = [
          inputs.files.flakeModules.default
          inputs.home-manager.flakeModules.home-manager
        ];
        flake = {
          lib = import ./lib.nix inputs;
          nixosModules = self.lib.import-all ./nixos-modules;
          homeManagerModules = self.lib.import-all ./home-modules;
          overlays = {
            wtf = final: prev: {
              wtf = final.callPackage ./packages/wtf.nix {};
            };
            always-redraw-progress-bar-on-log-output = final: prev: {
              nix = prev.nix.overrideAttrs (old: {
                patches =
                  (old.patches or [])
                  ++ [
                    ./patches/nix/always-redraw-progress-bar-on-log-output.patch
                  ];
              });
            };
          };
          nixosConfigurations = builtins.mapAttrs self.lib.mkNixosSystem (self.lib.import-all ./hosts);
        };
        systems = [
          "x86_64-linux"
        ];
        perSystem = {
          config,
          pkgs,
          ...
        }: {
          apps = {
            update-files = {
              program = with config.files.writer; "${drv}/bin/${exeFilename}";
              meta = {
                description = "Update dynamically generated files in repository";
              };
            };
          };
          packages = {
            wtf = pkgs.callPackage ./packages/wtf.nix {};
          };
          files.files = let
            nix-mineral-patched = pkgs.applyPatches {
              name = "nix-mineral-patched";
              src = inputs.nix-mineral;
              patches = [
                ./nixos-modules/hardening/override.patch
              ];
            };
          in [
            {
              drv = pkgs.runCommand "nix-mineral.nix-patched" {} ''
                cp ${nix-mineral-patched}/nix-mineral.nix $out
              '';
              path_ = "./nixos-modules/hardening/nix-mineral.nix";
            }
            {
              drv = pkgs.runCommand "sources.toml" {} ''
                cp ${nix-mineral-patched}/sources.toml $out
              '';
              path_ = "./nixos-modules/hardening/sources.toml";
            }
          ];
          formatter = pkgs.alejandra;
        };
      }
    );
}
