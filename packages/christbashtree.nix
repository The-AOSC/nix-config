{
  stdenv,
  fetchFromGitHub,
  ...
}:
stdenv.mkDerivation {
  name = "christbashtree";
  src = fetchFromGitHub {
    owner = "sergiolepore";
    repo = "ChristBASHTree";
    rev = "bfea545af6d82f7b72f3ea1df816ee9262b2bc57";
    hash = "sha256-VSMGOM3cxWIZvIBIT41k28aPeJd/eeHn1WE53a+Hgh8=";
  };
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp tree-EN.sh $out/bin/bash-tree
    runHook postInstall
  '';
}
