{
  config,
  lib,
  ...
}: {
  options = {
    modules.amd.enable = lib.mkEnableOption "amd";
  };
  config = lib.mkIf config.modules.amd.enable {
    hardware.amdgpu = {
      amdvlk = {
        enable = true;
        support32Bit.enable = true;
      };
      opencl = {
        enable = true;
      };
    };
  };
}
