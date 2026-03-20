top @ {inputs, ...}: {
  imports = [
    inputs.ez-configs.flakeModule
    inputs.files.flakeModules.default
    inputs.flake-parts.flakeModules.easyOverlay
    inputs.home-manager.flakeModules.home-manager
  ];
  ezConfigs = {
    root = builtins.toString ../.;
    globalArgs = {
      inherit inputs;
    };
    nixos.hosts.evacuis.userHomeModules = ["aosc"];
  };
  flake = {
    debug = top;
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
                        ../patches/tree-sitter-nix/remove-is-not.patch
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
              ../patches/hypridle/hyprlock-wait-for-fadein.patch
            ];
        });
        hyprlock = prev.hyprlock.overrideAttrs (old: {
          patches =
            old.patches or []
            ++ [
              ../patches/hyprlock/hypridle-wait-for-fadein.patch
            ];
        });
      };
      wpctl-add-db-gain-change-support = final: prev: {
        wireplumber = prev.wireplumber.overrideAttrs (old: {
          patches =
            old.patches or []
            ++ [
              ../patches/wireplumber/wpctl-add-db-gain-change-support.patch
            ];
        });
      };
    };
  };
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
        christbashtree = final.callPackage ../packages/christbashtree.nix {};
        colorbindiff = final.callPackage ../packages/colorbindiff.nix {};
        mindustry150 = final.callPackage ../packages/mindustry/package.nix {};
        mindustry150-server = final.callPackage ../packages/mindustry/package.nix {
          enableClient = false;
          enableServer = true;
        };
        mindustry150-wayland = final.callPackage ../packages/mindustry/package.nix {
          enableWayland = true;
        };
        multi-dimensional-workspaces = final.callPackage ../packages/multi-dimensional-workspaces {
          inherit (final.hyprlandPlugins) mkHyprlandPlugin;
        };
        nixvim-configured = final.callPackage ../packages/nixvim/package.nix {};
        nix-flake-add-roots = final.callPackage ../packages/nix-flake-add-roots {};
        stylus = final.callPackage ../packages/stylus {
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
        wine-staging-fixed = let
          wine = final.wineWow64Packages.stagingFull.override {
            #gstreamerSupport = false;
          };
          wine-mono = final.fetchurl rec {
            # https://gitlab.winehq.org/wine/wine/-/wikis/Wine-Mono#versions
            version = "10.4.1";
            url = "https://dl.winehq.org/wine/wine-mono/${version}/wine-mono-${version}-x86.msi";
            hash = "sha256-Bx9LKIfhyXoR15H/PWW+lCnu1t7EwnCIiL/VRro1jiM=";
          };
        in
          pkgs.runCommand wine.name {
            inherit (wine) meta;
            passthru =
              wine.passthru
              // {
                inherit wine;
              };
          } ''
            cp ${wine} $out -ra
            chmod +200 $out -R
            # TODO: substitute only hashes
            find $out -type f | xargs sed -i "s#${wine.outPath}#$out#g"
            ln -s ${wine-mono} $out/share/wine/mono/${wine-mono.name}
          '';
        wtf = final.callPackage ../packages/wtf.nix {};
      }
      # https://github.com/ners/nix-monitored/issues/3
      // builtins.mapAttrs (name: app: pkgs.writeShellScriptBin name ''exec "$0" ${app.program} "$@"'') config.apps;
    apps = {
      nixos-anywhere-install-for = {
        program = lib.getExe (pkgs.callPackage ../packages/nixos-anywhere-install-for {});
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
  };
}
