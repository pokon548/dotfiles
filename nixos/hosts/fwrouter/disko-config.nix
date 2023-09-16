{ disk ? null, ... }: {
  disk.nixos = {
    device = disk;
    type = "disk";
    content = {
      type = "table";
      format = "gpt";
      partitions = {
        ESP = {
          size = "100M";
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
  };
}
