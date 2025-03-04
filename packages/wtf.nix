{lib, pkgs, ...}: {
  nixpkgs.overlays = [
    (final: prev: {
      wtf = pkgs.stdenv.mkDerivation rec {
        pname = "wtf";
        version = "20230906";
        src = pkgs.fetchurl {
          url = "https://sourceforge.net/projects/bsd${pname}/files/${pname}-${version}.tar.gz";
          hash = "sha256-7ZwfqSf82HjM6VX7C9xYaHbuGuI0ZmvnXDu9blsqCUs=";
        };
        installPhase = ''
          mkdir -p $out/bin
          mkdir -p $out/share/man/man6
          mkdir -p $out/share/misc
          cp wtf $out/bin
          sed -i "s#/usr/share/misc/#$out/share/misc/#g" $out/bin/wtf
          chmod +x $out/bin/wtf
          cp wtf.6 $out/share/man/man6
          sed -i "s#/usr/share/misc/#$out/share/misc/#g" $out/share/man/man6/wtf.6
          cp acronyms* $out/share/misc
        '';
      };
      meta = {
        homepage = "https://netbsd.org/";
        description = "Translates acronyms for you";
        license = lib.licenses.bsd3;  # probably
      };
    })
  ];
}
