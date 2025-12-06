{
  lib,
  stdenv,
  fetchFromGitHub,
  makeWrapper,
  ncurses,
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
  nativeBuildInputs = [
    makeWrapper
  ];
  installPhase = ''
    runHook preInstall
    mkdir -p $out/bin
    cp tree-EN.sh $out/bin/bash-tree
    wrapProgram $out/bin/bash-tree \
      --prefix PATH : ${lib.makeBinPath [ncurses]}
    runHook postInstall
  '';
  meta = {
    description = "Just a Christmas tree";
    license = lib.licenses.unlicense;
    mainProgram = "bash-tree";
  };
}
