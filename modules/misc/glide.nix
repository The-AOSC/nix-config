{
  inputs,
  lib,
  ...
}: {
  flake-file.inputs.glide.url = "github:tompassarelli/glide";
  flake.aspects.glide = instance: {
    nixos = {
      config,
      pkgs,
      ...
    }: {
      imports = [inputs.glide.nixosModules.default];
      services.kanata.keyboards.${instance}.port = 7070;
      modules.kanata.keyboards.${instance}.extraConfig = ''
        (defvirtualkeys
          pad-touch (switch
                      ((base-layer default)) (layer-while-held default-mouse) break
                      ((base-layer simple)) (layer-while-held mouse) break))
      '';
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
            execve("${lib.getExe inputs.glide.packages.${pkgs.stdenv.hostPlatform.system}.default}", argv, NULL);
          }
        '';
        # activate immediately on touch
        motionThreshold = 0;
        minStreak = 0;
      };
    };
  };
}
