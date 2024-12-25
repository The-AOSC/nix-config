{lib, pkgs, ...}: {
  nixpkgs.overlays = [
    (final: prev: {
      zapret = pkgs.stdenv.mkDerivation rec {
        pname = "zapret";
        version = "69.8";
        buildInputs = with pkgs; [
          libcap
          zlib
          libnetfilter_queue
          libnfnetlink
        ];
        src = pkgs.fetchFromGitHub {
          owner = "bol-van";
          repo = "zapret";
          rev = "9c8636081c413dcc08ea6ce8eb33a36798908a8e";
          hash = "sha256-5wylVEE1kqZdUxntRvXdLdnRMoZ1QhmdSJaLm5IVHLU=";
        };
      };
    })
  ];
}
