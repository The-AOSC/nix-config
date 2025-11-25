{
  config,
  pkgs,
  lib,
  ...
}: {
  options = {
    modules.tor.enable = lib.mkEnableOption "tor";
  };
  config = lib.mkIf config.modules.tor.enable {
    home.packages = [
      (pkgs.nyx.overridePythonAttrs (old: {
        version = "2.1.0+unstable-2022-06-27";
        src = pkgs.fetchFromGitHub {
          owner = "torproject";
          repo = "nyx";
          rev = "dcaddf2ab7f9d2ef8649f98bb6870995ebe0b893";
          hash = "sha256-Ccwa6LpyHz0e1Uk15NbRHTl62INReRfsIXCqdQjOg+c=";
        };
        patches = [
          ./remove-distutils.patch
        ];
        dependencies = [
          (pkgs.python3Packages.stem.overrideAttrs (old: {
            version = "1.8.3";
            src = pkgs.fetchFromGitHub {
              owner = "torproject";
              repo = "stem";
              rev = "1.8.3";
              hash = "sha256-FK7ldpOGEQ+VYLgwL7rGSGNtD/2iz11b0YOa78zNGDk=";
            };
            patches = [];
            doInstallCheck = false;
          }))
        ];
      }))
    ];
  };
}
