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
      url = "github:catppuccin/userstyles?rev=c9b357f2c40b1eea88e73c071b5d5587598f5206";
      flake = false;
    };
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
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
            multi-dimensional-workspaces = final: prev: {
              multi-dimensional-workspaces = final.callPackage ./packages/multi-dimensional-workspaces {
                inherit (final.hyprlandPlugins) mkHyprlandPlugin;
              };
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
            wine-fixes = final: prev: {
              wine-ge-fixed = final.wine-ge.overrideAttrs (old: {
                patches =
                  old.patches or []
                  ++ [
                    # See https://gitlab.winehq.org/wine/wine/-/merge_requests/7328
                    (final.fetchpatch2 {
                      url = "https://gitlab.winehq.org/wine/wine/-/commit/c9519f68ea04915a60704534ab3afec5ec1b8fd7.patch";
                      hash = "sha256-b36pa0EdJnOeuZ8+21QfS30WMSEHKTPQpnXsTvmtw30=";
                    })
                    (final.fetchpatch2 {
                      url = "https://gitlab.winehq.org/wine/wine/-/commit/fd59962827a715d321f91c9bdb43f3e61f9ebbcb.patch";
                      hash = "sha256-ssPEdzjE+R4KbLFrasf279bX++bhzC+K/LXxhAL5liI=";
                    })
                  ];
                postInstall = let
                  wine-mono = final.fetchurl rec {
                    # https://gitlab.winehq.org/wine/wine/-/wikis/Wine-Mono#versions
                    hash = "sha256-DtPsUzrvebLzEhVZMc97EIAAmsDFtMK8/rZ4rJSOCBA=";
                    version = "wine-mono-8.1.0";
                    url = "https://github.com/wine-mono/wine-mono/releases/download/${version}/${version}-x86.msi";
                  };
                in ''
                  ${old.postInstall or ""}
                  ln -s ${wine-mono} $out/share/wine/mono/${wine-mono.name}
                '';
              });
              wine-staging-fixed =
                (final.wineWowPackages.stagingFull.overrideAttrs (old: {
                  /*
                  postInstall = let
                    wine-mono = final.fetchurl rec {
                      # https://gitlab.winehq.org/wine/wine/-/wikis/Wine-Mono#versions
                      hash = "";
                      version = "wine-mono-...";
                      url = "https://github.com/wine-mono/wine-mono/releases/download/${version}/${version}-x86.msi";
                    };
                  in ''
                    ${old.postInstall or ""}
                    ln -s ${wine-mono} $out/share/wine/mono/${wine-mono.name}
                  '';
                  */
                })).override {
                  gstreamerSupport = false;
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
            multi-dimensional-workspaces = pkgs.callPackage ./packages/multi-dimensional-workspaces {
              inherit (pkgs.hyprlandPlugins) mkHyprlandPlugin;
            };
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
