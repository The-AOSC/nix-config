top @ {inputs, ...}: {
  imports = [
    inputs.ez-configs.flakeModule
    inputs.flake-parts.flakeModules.easyOverlay
    inputs.home-manager.flakeModules.home-manager
  ];
  ezConfigs = {
    nixos.configurationsDirectory = "${inputs.self}/non-existent-directory";
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
        nixvim-configured = final.callPackage ../packages/nixvim/package.nix {inherit (inputs.nixvim.inputs) nixpkgs;};
        nix-flake-add-roots = final.callPackage ../packages/nix-flake-add-roots {};
        stylus = final.callPackage ../packages/stylus {
          stylus-nur = final.nur.repos.rycee.firefox-addons.stylus;
        };
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
    };
  };
}
