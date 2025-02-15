{config, ...}: {
  hardware.nvidia = {
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    prime = {
      # 00:02.0 VGA compatible controller: Intel Corporation WhiskeyLake-U GT2 [UHD Graphics 620]
      intelBusId = "PCI:0:2:0";
      # 02:00.0 3D controller: NVIDIA Corporation GP108M [GeForce MX250] (rev a1)
      nvidiaBusId = "PCI:2:0:0";
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };
      #reverseSync.enable = true;
    };
    open = false;
    powerManagement.enable = true;
    #modesetting.enable = true;  # TODO
  };
  services.xserver.videoDrivers = ["nvidia"];  # WTF?
  modules.modules.allow-unfree.allowUnfree = [
    "nvidia-x11"
    "nvidia-settings"
  ];
}
