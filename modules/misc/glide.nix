{inputs, ...}: {
  flake-file.inputs.glide.url = "github:tompassarelli/glide";
  flake.aspects.glide = instance: device: {
    nixos = {
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
        inherit device;
        # activate immediately on touch
        motionThreshold = 0;
        minStreak = 0;
      };
    };
  };
}
