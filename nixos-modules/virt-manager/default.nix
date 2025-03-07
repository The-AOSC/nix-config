{
  inputs,
  config,
  pkgs,
  lib,
  ...
}: {
  programs.virt-manager = {
    enable = true;
  };
  virtualisation.libvirt = {
    enable = true;
    connections."qemu:///system" = {
      domains = null; # do not manage
      networks = [
        {
          definition = inputs.nixvirt.lib.network.writeXML {
            name = "default";
            uuid = "c6d7391b-949e-4def-bcba-558a6e8e89f9";
            forward = {
              mode = "nat";
            };
            bridge = {
              name = "virbr0";
            };
            mac = {
              address = "52:54:00:ee:d0:ac";
            };
            ip = {
              address = "10.255.0.1";
              netmask = "255.255.0.0";
              dhcp = {
                range = {
                  start = "10.255.128.0";
                  end = "10.255.255.254";
                };
              };
            };
          };
          active = true;
        }
        {
          definition = inputs.nixvirt.lib.network.writeXML {
            name = "local";
            uuid = "16267002-294b-44c5-a58a-f271bef1b247";
            bridge = {
              name = "virbr1";
            };
            mac = {
              address = "52:54:00:09:27:88";
            };
            ip = {
              address = "10.254.0.1";
              netmask = "255.255.0.0";
              dhcp = {
                range = {
                  start = "10.254.128.0";
                  end = "10.254.255.254";
                };
              };
            };
          };
          active = true;
        }
      ];
      pools = [
        {
          definition = inputs.nixvirt.lib.pool.writeXML {
            name = "iso";
            uuid = "76d05dc9-76a8-410e-bf8c-6188490e1401";
            type = "dir";
            target = {
              path = "/var/iso";
            };
          };
          active = true;
          volumes = [];
        }
        {
          definition = inputs.nixvirt.lib.pool.writeXML {
            name = "vms";
            uuid = "93d8383e-8b45-4aea-ac28-cd5f24b742bf";
            type = "dir";
            target = {
              path = "/var/vms";
            };
          };
          active = true;
          volumes = [];
        }
      ];
    };
  };
  virtualisation.libvirtd = {
    onBoot = "ignore";
    onShutdown = "suspend";
    qemu = {
      package =
        if ((lib.length config.boot.binfmt.emulatedSystems) == 0)
        then pkgs.qemu_kvm
        else pkgs.qemu;
      runAsRoot = true;
    };
  };
  virtualisation.spiceUSBRedirection.enable = true;
  # enable UEFI firmware support in Virt-Manager, Libvirt, Gnome-Boxes etc
  systemd.tmpfiles.rules = [
    "L+ /var/lib/qemu/firmware - - - - ${pkgs.qemu}/share/qemu/firmware"
  ];
  users.users.aosc.extraGroups = [
    "libvirtd"
  ];
  environment.persistence."/persist" = {
    directories = [
      "/var/iso"
      "/var/lib/libvirt/images"
      "/var/lib/libvirt/qemu"
      "/var/vms"
    ];
  };
}
