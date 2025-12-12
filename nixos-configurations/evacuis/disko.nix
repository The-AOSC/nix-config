{
  disko.devices = {
    disk.system = {
      device = "/dev/disk/by-id/nvme-WD_PC_SN740_SDDQNQD-1T00-1014_241006802182";
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
            size = "32G";
            priority = 500;
            content = {
              type = "swap";
            };
          };
          nix = {
            size = "250G";
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
    disk.media = {
      device = "/dev/disk/by-id/nvme-ADATA_LEGEND_960_2O352LAQA117";
      content = {
        type = "gpt";
        partitions = {
          media = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "btrfs";
              mountpoint = "/media";
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
