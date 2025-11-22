{
  disko.devices = {
    disk.system = {
      device = "/dev/disk/by-id/ata-ST1000LM035-1RK172_WL1XYZ8E";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            type = "EF00"; # EFI system partition
            end = "1G"; # start: 1M; size: 1023M
            priority = 200;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = ["umask=0077"];
            };
          };
          swap = {
            size = "16G";
            priority = 500;
            content = {
              type = "swap";
            };
          };
          nix = {
            size = "200G";
            #priority = 1000;
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/nix";
            };
          };
          persist = {
            size = "100%";
            #priority = 9100;
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/persist";
            };
          };
        };
      };
    };
    nodev = {
      "/" = {
        fsType = "tmpfs";
        mountOptions = ["mode=755"];
      };
    };
  };
}
