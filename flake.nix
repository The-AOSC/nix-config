{
  description = "NixOS configuration of The AOSC";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    impermanence = {
      url = "github:nix-community/impermanence";
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
      inputs.flake-compat.follows = "nom/git-hooks/flake-compat";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
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
      url = "github:maralorn/nix-output-monitor?rev=c1c48a07a55735379add43cb5b7df287d22f1e7e";
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
    ez-configs = {
      url = "github:ehllie/ez-configs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lan-mouse = {
      url = "github:feschber/lan-mouse";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.systems.follows = "nom/flake-utils/systems";
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
          inputs.ez-configs.flakeModule
          inputs.files.flakeModules.default
          inputs.flake-parts.flakeModules.easyOverlay
          inputs.home-manager.flakeModules.home-manager
        ];
        ezConfigs = {
          root = builtins.toString ./.;
          globalArgs = {
            inherit inputs;
          };
          nixos.hosts.evacuis.userHomeModules = ["aosc"];
        };
        flake = {
          overlays = {
            fix-nvim-tree-sitter-grammars = final: prev: {
              tree-sitter =
                prev.tree-sitter
                // {
                  allGrammars =
                    builtins.map (grammar:
                      if grammar.pname == "tree-sitter-nix"
                      then
                        grammar.overrideAttrs (old: {
                          patches =
                            old.patches or []
                            ++ [
                              ./patches/tree-sitter-nix/remove-is-not.patch
                            ];
                        })
                      else grammar)
                    (builtins.filter
                      (grammar:
                        !(builtins.elem grammar.pname [
                          "tree-sitter-@tlaplus/tlaplus"
                        ]))
                      prev.tree-sitter.allGrammars);
                };
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
            wpctl-add-db-gain-change-support = final: prev: {
              wireplumber = prev.wireplumber.overrideAttrs (old: {
                patches =
                  old.patches or []
                  ++ [
                    ./patches/wireplumber/wpctl-add-db-gain-change-support.patch
                  ];
              });
            };
          };
        };
        systems = [
          "x86_64-linux"
        ];
        perSystem = {
          config,
          system,
          final,
          pkgs,
          lib,
          ...
        }: {
          overlayAttrs =
            {
              inherit
                (config.packages)
                catppuccin-userstyles
                christbashtree
                colorbindiff
                mindustry150
                mindustry150-server
                mindustry150-wayland
                multi-dimensional-workspaces
                nix-flake-add-roots
                nixvim-configured
                stylus
                wine-ge-fixed
                wine-staging-fixed
                wtf
                ;
            }
            # those overlays provide required dependencies for flake.packages;
            # note that they applied as part of flake.overlays.default instead of normal chaining
            // (inputs.nix-gaming.overlays.default final pkgs)
            // (inputs.nixvim.overlays.default final pkgs)
            // (inputs.nur.overlays.default final pkgs);
          packages =
            {
              catppuccin-userstyles = final.callPackage ./packages/catppuccin-userstyles.nix {
                src = inputs.catppuccin-userstyles;
                inherit
                  (import inputs.nixpkgs-buildDenoPackage {
                    inherit system;
                  })
                  buildDenoPackage
                  ;
              };
              christbashtree = final.callPackage ./packages/christbashtree.nix {};
              colorbindiff = final.callPackage ./packages/colorbindiff.nix {};
              mindustry150 = final.callPackage ./packages/mindustry/package.nix {};
              mindustry150-server = final.callPackage ./packages/mindustry/package.nix {
                enableClient = false;
                enableServer = true;
              };
              mindustry150-wayland = final.callPackage ./packages/mindustry/package.nix {
                enableWayland = true;
              };
              multi-dimensional-workspaces = final.callPackage ./packages/multi-dimensional-workspaces {
                inherit (final.hyprlandPlugins) mkHyprlandPlugin;
              };
              nixvim-configured = final.callPackage ./packages/nixvim/package.nix {};
              nix-flake-add-roots = final.callPackage ./packages/nix-flake-add-roots {};
              stylus = final.callPackage ./packages/stylus {
                stylus-nur = final.nur.repos.rycee.firefox-addons.stylus;
              };
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
              wtf = final.callPackage ./packages/wtf.nix {};
            }
            # https://github.com/ners/nix-monitored/issues/3
            // builtins.mapAttrs (name: app: pkgs.writeShellScriptBin name ''exec "$0" ${app.program} "$@"'') config.apps;
          apps = {
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
          files.files = [];
          formatter = pkgs.alejandra;
        };
      }
    );
}
