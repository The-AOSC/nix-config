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
    nix-index-database.url = "github:nix-community/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";
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
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-buildDenoPackage.url = "github:aMOPel/nixpkgs/feat/buildDenoPackage-second";
    nom = {
      url = "github:maralorn/nix-output-monitor";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-monitored = {
      url = "github:ners/nix-monitored";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
          nixosModules = self.lib.import-all ./nixosModules;
          homeModules = self.lib.import-all ./homeModules;
          overlays = {
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
            hypridle-wait-for-hyprlock-fadein = final: prev: {
              hypridle = prev.hypridle.overrideAttrs (old: {
                patches =
                  old.patches or []
                  ++ [
                    ./patches/hypridle/hyprlock-wait-for-fadein.patch
                  ];
              });
              hyprlock = prev.hyprlock.overrideAttrs (old: {
                patches =
                  old.patches or []
                  ++ [
                    ./patches/hyprlock/hypridle-wait-for-fadein.patch
                  ];
              });
            };
            multi-dimensional-workspaces = final: prev: {
              multi-dimensional-workspaces = final.callPackage ./packages/multi-dimensional-workspaces {
                inherit (final.hyprlandPlugins) mkHyprlandPlugin;
              };
            };
            nix-flake-add-roots = final: prev: {
              nix-flake-add-roots = final.callPackage ./packages/nix-flake-add-roots {};
            };
            fix-ssh-copy-id = final: prev: {
              ssh-copy-id = prev.ssh-copy-id.overrideAttrs (old: {
                buildInputs =
                  old.buildInputs or []
                  ++ [
                    final.bash
                  ];
                buildCommand = ''
                  ${old.buildCommand}
                  patchShebangs --host $out/bin/ssh-copy-id
                '';
              });
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
              wine-ge-fixed = final.wine-ge.overrideAttrs (finalAttrs: old: {
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
                (final.wineWowPackages.stagingFull.overrideAttrs (finalAttrs: old: {
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
            wpctl-add-db-gain-change-support = final: prev: {
              wireplumber = prev.wireplumber.overrideAttrs (old: {
                patches =
                  old.patches or []
                  ++ [
                    ./patches/wireplumber/wpctl-add-db-gain-change-support.patch
                  ];
              });
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
          lib,
          ...
        }: {
          apps = {
            nix-flake-add-roots = {
              program = lib.getExe (pkgs.callPackage ./packages/nix-flake-add-roots {});
              meta = {
                description = "Create gc-roots of flake inputs";
              };
            };
            nixos-anywhere-install-for = {
              program = lib.getExe (pkgs.callPackage ./packages/nixos-anywhere-install-for {});
              meta = {
                description = "Wrapper around nixos-anywhere for use with this flake";
              };
            };
            update-files = {
              program = with config.files.writer; "${drv}/bin/${exeFilename}";
              meta = {
                description = "Update dynamically generated files in repository";
              };
            };
          };
          packages =
            {
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
            }
            # https://github.com/ners/nix-monitored/issues/3
            // builtins.mapAttrs (name: app: pkgs.writeShellScriptBin name ''exec "$0" ${app.program} "$@"'') config.apps;
          files.files = let
            nix-mineral-patched = pkgs.applyPatches {
              name = "nix-mineral-patched";
              src = inputs.nix-mineral;
              patches = [
                ./nixosModules/hardening/override.patch
              ];
            };
          in [
            {
              drv = pkgs.runCommand "nix-mineral.nix-patched" {} ''
                cp ${nix-mineral-patched}/nix-mineral.nix $out
              '';
              path_ = "./nixosModules/hardening/nix-mineral.nix";
            }
            {
              drv = pkgs.runCommand "sources.toml" {} ''
                cp ${nix-mineral-patched}/sources.toml $out
              '';
              path_ = "./nixosModules/hardening/sources.toml";
            }
          ];
          formatter = pkgs.alejandra;
        };
      }
    );
}
