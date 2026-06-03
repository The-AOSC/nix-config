{inputs, ...}: {
  flake.aspects.base.nixos.nixpkgs.overlays = [
    (final: prev: {
      # https://github.com/NixOS/nixpkgs/pull/523359/commits/6b5f8083d4aea8d1a30e114a2c3166c57aa861b2
      jitterentropy-rngd = prev.jitterentropy-rngd.overrideAttrs (old: {
        patches =
          old.patches or []
          ++ [
            (final.fetchpatch2 {
              url = "https://github.com/smuellerDD/jitterentropy-rngd/compare/61ad2e7c83b95402536b90b52eabe20ce60cfbd7...cee0c7a035e9564d161053012c6ea36b2ce27383.patch";
              hash = "sha256-e112LAqIlNL1oGd01wAON0aWZKAOoMznpwQx64DS4OE=";
            })
          ];
      });
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
        wine = final.wineWow64Packages.stagingFull;
        wine-mono = final.fetchurl rec {
          # https://gitlab.winehq.org/wine/wine/-/wikis/Wine-Mono#versions
          version = "11.1.0";
          url = "https://dl.winehq.org/wine/wine-mono/${version}/wine-mono-${version}-x86.msi";
          hash = "sha256-3rA0FDH4Jgsgn/9rx53cxUFLl/jpI2q5+9ykzlngqbk=";
        };
      in
        final.runCommand wine.name {
          inherit (wine) meta;
          passthru =
            wine.passthru
            // {
              inherit wine;
            };
        } ''
          cp ${wine} $out -ra
          chmod +200 $out -R
          find $out -type f | xargs sed -i "s#$(sed "s#/nix/store/\([0-9a-z]*\)-.*#\1#" <<< "${wine.outPath}")#$(sed "s#/nix/store/\([0-9a-z]*\)-.*#\1#" <<< "$out")#g"
          ln -s ${wine-mono} $out/share/wine/mono/${wine-mono.name}
        '';
      wireshark = prev.wireshark.overrideAttrs (old: {
        patches =
          old.patches or []
          ++ [
            ../patches/wireshark/4.6.5-disable-sidebar.patch
          ];
      });
    })
  ];
}
