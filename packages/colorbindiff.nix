{
  dos2unix,
  fetchurl,
  lib,
  perl,
  stdenv,
  ...
}:
stdenv.mkDerivation rec {
  pname = "colorbindiff";
  version = "1.0";
  src = fetchurl {
    url = "https://github.com/jjazzboss/colorbindiff/archive/refs/tags/${version}.tar.gz";
    hash = "sha256-9bwMAlhJD8Nrqi0Fg2LMJM5eSQ5w2zmSmMNx1LROu+k=";
  };
  nativeBuildInputs = [
    dos2unix
  ];
  buildInputs = [
    perl
  ];
  postPatch = ''
    dos2unix colorbindiff.pl
  '';
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp colorbindiff.pl $out/bin/colorbindiff
    chmod +x $out/bin/colorbindiff
    runHook postInstall
  '';
  meta = {
    homepage = "https://github.com/jjazzboss/colorbindiff";
    description = "A visual and colorized diff for binary files.";
    license = lib.licenses.lgpl3;
  };
}
