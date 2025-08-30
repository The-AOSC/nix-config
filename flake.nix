{
  description = "NixOS configuration of The AOSC";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-3ecd031b66320e5ca9837b3b994fca8292967112.url = "github:NixOS/nixpkgs?rev=3ecd031b66320e5ca9837b3b994fca8292967112"; # incompatible versions of wine-staging & wine-mono in bfeebf7b5c669ff3a7998214f9f649fcd2e5b1e7
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
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    nix-mineral = {
      url = "github:cynicsketch/nix-mineral";
      flake = false;
    };
    files.url = "github:mightyiam/files";
    nur = {
      url = "github:nix-community/NUR";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin-vimium = {
      url = "github:/catppuccin/vimium";
      flake = false;
    };
    catppuccin-userstyles = {
      url = "github:catppuccin/userstyles";
      flake = false;
    };
    nixpkgs-buildDenoPackage.url = "github:aMOPel/nixpkgs/feat/buildDenoPackage-second";
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
            always-redraw-progress-bar-on-log-output = final: prev: {
              nix = prev.nix.overrideAttrs (old: {
                patches =
                  (old.patches or [])
                  ++ [
                    ./patches/nix/always-redraw-progress-bar-on-log-output.patch
                  ];
              });
            };
            catppuccin-userstyles = final: prev: {
              catppuccin-userstyles = final.callPackage ./packages/catppuccin-userstyles.nix {
                src = inputs.catppuccin-userstyles;
                inherit
                  (import inputs.nixpkgs-buildDenoPackage {
                    inherit (final) system;
                  })
                  buildDenoPackage
                  ;
              };
            };
            christbashtree = final: prev: {
              christbashtree = final.callPackage ./packages/christbashtree.nix {};
            };
            colorbindiff = final: prev: {
              colorbindiff = final.callPackage ./packages/colorbindiff.nix {};
            };
            stylus = final: prev: {
              stylus = final.callPackage ./packages/stylus {
                stylus-nur = final.nur.repos.rycee.firefox-addons.stylus;
              };
            };
            update-mindustry = final: prev: {
              mindustry = final.callPackage ./packages/mindustry/package.nix {};
              mindustry-wayland = final.callPackage ./packages/mindustry/package.nix {
                enableWayland = true;
              };
              mindustry-server = final.callPackage ./packages/mindustry/package.nix {
                enableClient = false;
                enableServer = true;
              };
            };
            wtf = final: prev: {
              wtf = final.callPackage ./packages/wtf.nix {};
            };
          };
          nixosConfigurations = builtins.mapAttrs self.lib.mkNixosSystem (self.lib.import-all ./hosts);
        };
        systems = [
          "x86_64-linux"
        ];
        perSystem = {
          config,
          system,
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
            catppuccin-userstyles = pkgs.callPackage ./packages/catppuccin-userstyles.nix {
              src = inputs.catppuccin-userstyles;
              inherit
                (import inputs.nixpkgs-buildDenoPackage {
                  inherit system;
                })
                buildDenoPackage
                ;
            };
            christbashtree = pkgs.callPackage ./packages/christbashtree.nix {};
            colorbindiff = pkgs.callPackage ./packages/colorbindiff.nix {};
            mindustry = pkgs.callPackage ./packages/mindustry/package.nix {};
            stylus = pkgs.callPackage ./packages/stylus {
              stylus-nur = inputs.nur.legacyPackages."${system}".repos.rycee.firefox-addons.stylus;
            };
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
