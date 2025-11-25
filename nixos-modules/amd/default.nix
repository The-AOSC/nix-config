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
      opencl = {
        enable = true;
      };
    };
  };
}
