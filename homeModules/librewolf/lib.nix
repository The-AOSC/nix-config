{pkgs, ...}: {
  lib.librewolf = {
    patchExtension = extension: patches: extra: let
      extensionPath = "extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}";
    in
      pkgs.stdenv.mkDerivation ({
          name = "${extension.name}-patched";
          src = "${extension}/share/mozilla/${extensionPath}/${extension.addonId}.xpi";
          unpackPhase = ''
            runHook preUnpack
            mkdir extension
            cd extension
            ${pkgs.unzip}/bin/unzip $src
            runHook postUnpack
          '';
          installPhase = ''
            runHook preInstall
            mkdir -p $out/share/mozilla/${extensionPath}
            ${pkgs.zip}/bin/zip -r $out/share/mozilla/${extensionPath}/${extension.addonId}.xpi -- *
            runHook postInstall
          '';
          inherit patches;
          inherit (extension) meta;
          passthru = {
            inherit (extension) addonId mozPermissions;
          };
        }
        // extra);
  };
}
