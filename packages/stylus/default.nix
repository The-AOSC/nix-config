{
  stdenv,
  fetchurl,
  pnpm_10,
  nodejs,
  zip,
  lib,
  stylus-nur,
  ...
}: let
  pnpm = pnpm_10;
  extensionPath = "extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}";
in
  stdenv.mkDerivation rec {
    pname = "stylus";
    version = "2.3.16";
    src = fetchurl {
      url = "https://github.com/openstyles/stylus/archive/refs/tags/v${version}.tar.gz";
      hash = "sha256-bLmB/8wASoj4WWb81uZS2rhXldYYpfH3Q94Cp4U6zNA=";
    };
    patches = [
      ./declarative-stylus.patch
    ];
    nativeBuildInputs = [
      nodejs
      pnpm.configHook
    ];
    pnpmDeps = pnpm.fetchDeps {
      inherit pname version src;
      fetcherVersion = 2;
      hash = "sha256-ua5n5ZBNwUr9PfUy2UKAlC8ao0vzTvXhjUjsiEzPp6w=";
    };
    buildPhase = ''
      runHook preBuild
      pnpm build-firefox
      pnpm zip-firefox
      runHook postBuild
    '';
    installPhase = ''
      mkdir -p $out/share/mozilla/${extensionPath}
      mv stylus-firefox-${version}.zip $out/share/mozilla/${extensionPath}/${passthru.addonId}.xpi
    '';
    meta = {
      homepage = "https://github.com/openstyles/stylus";
      description = "Redesign your favorite websites with Stylus, an actively developed and community driven userstyles manager. Easily install custom themes from popular online repositories, or create, edit, and manage your own personalized CSS stylesheets.";
      license = lib.licenses.bsd3;
    };
    passthru = {
      inherit (stylus-nur) addonId mozPermissions;
    };
  }
