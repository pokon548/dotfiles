{ config, self, pkgs, ... }:
{
  microvm.vms = {
    workvm = {
      config = {
        microvm = {
          hypervisor = "qemu";
          graphics.enable = true;
          qemu.extraArgs = [
            "-audiodev" "pipewire,id=auddev0"
            "-device" "intel-hda"
            "-device" "hda-output,audiodev=auddev0"
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
              source = "/nix/store";
              mountPoint = "/nix/.ro-store";
              tag = "ro-store";
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
