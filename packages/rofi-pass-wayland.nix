{
  lib,
  stdenv,
  fetchFromGitHub,
  makeBinaryWrapper,
  unstableGitUpdater,
  coreutils,
  util-linuxMinimal,
  gnugrep,
  libnotify,
  pwgen,
  findutils,
  gawk,
  gnused,
  qrencode,
  rofi,
  pass-wayland,
  wl-clipboard,
  wtype,
}:
stdenv.mkDerivation {
  pname = "rofi-pass";
  version = "2.0.2-unstable-2024-06-16";

  src = fetchFromGitHub {
    owner = "Seme4eg";
    repo = "rofi-pass-wayland";
    rev = "2ba0d0decf9b3e7fe9cd2bda5f8ccb933a29c63f";
    hash = "sha256-vLkbrwvD25ZLHtqMESjV9zyBwcOFs54ZI0JbXGeVBJE=";
  };

  nativeBuildInputs = [makeBinaryWrapper];

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -a rofi-pass $out/bin/rofi-pass

    mkdir -p $out/share/doc/rofi-pass/
    cp -a config.example $out/share/doc/rofi-pass/config.example

    runHook postInstall
  '';

  wrapperPath = lib.makeBinPath [
    coreutils
    findutils
    gawk
    gnugrep
    gnused
    libnotify
    pwgen
    qrencode
    rofi
    util-linuxMinimal
    (pass-wayland.withExtensions (ext: [ext.pass-otp]))
    wl-clipboard
    wtype
  ];

  fixupPhase = ''
    runHook preFixup

    patchShebangs $out/bin

    wrapProgram $out/bin/rofi-pass \
      --prefix PATH : "$wrapperPath"

    runHook postFixup
  '';

  passthru.updateScript = unstableGitUpdater {};

  meta = {
    description = "Script to make rofi work with password-store";
    mainProgram = "rofi-pass";
    homepage = "https://github.com/Seme4eg/rofi-pass-wayland";
    license = lib.licenses.mit;
    platforms = with lib.platforms; linux;
    maintainers = [];
  };
}
