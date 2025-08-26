{
  buildDenoPackage,
  src,
  lib,
  ...
}:
buildDenoPackage {
  name = "userstyles";
  version = "unstable";
  inherit src;
  denoDepsHash = "sha256-Ub+jBqMENprpGlSyHlYuBUVmq8cce1hA5AKQ4zmvfus=";
  denoTaskScript = "ci:stylus-import";
  installPhase = ''
    runHook preInstall
    mkdir $out
    cp dist/import.json $out
    runHook postInstall
  '';
  meta = {
    description = "A collection of userstyles for various websites.";
    homepage = "https://github.com/catppuccin/userstyles";
    license = lib.licenses.mit;
  };
}
