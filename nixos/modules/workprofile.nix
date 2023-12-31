{ config, self, pkgs, nixosTestRunner? false, ... }:
{
  microvm.vms = {
    workvm = {
      config = {
        microvm = {
          hypervisor = "qemu";
          graphics.enable = true;
          qemu.extraArgs = [
            "-audiodev"
            "pipewire,id=auddev0"
            "-device"
            "intel-hda"
            "-device"
            "hda-output,audiodev=auddev0"
            "-enable-kvm"
            "-device"
            "virtio-balloon"
            "-chardev"
            "qemu-vdagent,id=ch1,name=vdagent,clipboard=on"
            "-device"
            "virtio-serial-pci"
            "-device"
            "virtserialport,chardev=ch1,id=ch1,name=com.redhat.spice.0"
          ];
          interfaces = [
            {
              type = "user";
              id = "vm-netvm";
              mac = "02:00:00:01:01:01";
            }
          ];
          vcpu = 4;
          mem = 4096;
          shares = [
            {
              tag = "ro-store";
              source = "/nix/store";
              mountPoint = "/nix/.ro-store";
            }
            {
              tag = "rw-share";
              source = "/home/worker";
              mountPoint = "/home/worker/Share";
            }
          ];
          writableStoreOverlay = "/nix/.rw-store";
          volumes = [
            {
              image = "root-overlay.img";
              mountPoint = "/";
              size = 8192;
            }
          ];
        };

        imports = [ ../hosts/workvm ./i18n.nix ./font.nix ./fcitx5.nix ../home/worker.nix ];
      };
    };
  };
}
