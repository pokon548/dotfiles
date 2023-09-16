# Example to create a bios compatible gpt partition
{ lib, disks ? [ "/dev/vda" ], ... }: {
  disk = lib.genAttrs disks (dev: {
    device = dev;
    type = "disk";
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "100M";
          name = "ESP";
          content = {
            type = "filesystem";
            device = "by-partlabel";
            format = "vfat";
            mountpoint = "/boot";
          };
        };
        root = {
          end = "-512MiB";
          content = {
            type = "filesystem";
            device = "by-partlabel";
            format = "btrfs";
            mountOptions = [ "compress=zstd" ];
            mountpoint = "/";
          };
        };
        swap = {
          size = "100%";
          content = {
            type = "swap";
            device = "by-partlabel";
            randomEncryption = true;
          };
        };
      };
    };
  });
}
