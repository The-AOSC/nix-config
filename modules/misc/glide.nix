{
  inputs,
  lib,
  ...
}: {
  flake-file.inputs.glide.url = "github:tompassarelli/glide";
  den.aspects.glide = {
    nixos = {
      config,
      pkgs,
      ...
    }: {
      imports = [inputs.glide.nixosModules.default];
      options.services.glide.package = lib.mkOption {
        defaultText = ''inputs.glide.packages.''${pkgs.system}.default'';
      };
      config = {
        services.glide = {
          enable = true;
          # drop --device option
          package = pkgs.writeCBin "glide" ''
            #include <string.h>
            #include <unistd.h>
            int main(int argc, char **argv) {
              if (argc<1) {
                return 1;
              }
              char **arg = argv;
              while (*++arg) {
                if (!strcmp(*arg, "--device")) {
                  break;
                }
              }
              if (*(arg+1)) {
                while (*(arg+2)) {
                  *arg = *(arg+2);
                  arg++;
                }
              }
              *arg = NULL;
              argv[0] = "glide";
              execve("${lib.getExe' inputs.glide.packages.${pkgs.stdenv.hostPlatform.system}.default "glide"}", argv, NULL);
            }
          '';
          # activate immediately on touch
          motionThreshold = 0;
          minStreak = 0;
        };
      };
    };
  };
}
