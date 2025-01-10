{config, lib, ...}: {
  modules.options.sysrq = {
    userPackages = [];
    extraOptions = {
      mode = lib.mkOption {
        default = 1;
        type = with lib.types; addCheck (ints.between 0 511) (x: (x == 1) || ((bitAnd x 1) != 1));
        description = ''
          Functions allowed to be invoked by the SysRq key. Possible values are:

          0    Disable sysrq completely

          1    Enable all functions of sysrq

          > 1  Bit mask of allowed sysrq functions, as follows:
                 2  Enable control of console logging level
                 4  Enable control of keyboard (SAK, unraw)
                 8  Enable debugging dumps of processes etc.
                16  Enable sync command
                32  Enable remount read-only
                64  Enable signaling of processes (term, kill, oom-kill)
               128  Allow reboot/poweroff
               256  Allow nicing of all real-time tasks
        '';
      };
    };
  };
  boot.kernel.sysctl = config.modules.lib.withModuleSystemConfig "sysrq" {
    "kernel.sysrq" = config.modules.modules.sysrq.mode;
  };
}
