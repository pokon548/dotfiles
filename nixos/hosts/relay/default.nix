{ config, inputs, lib, pkgs, modulesPath, ... }:

{
  sops = {
    secrets = {
      ninjasight-config = { 
        sopsFile = ../../../secrets/relay.yaml;
      };
    };
  };

  imports = [
    "${inputs.nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
  ] ++ (with inputs.nixos-hardware.nixosModules;
    [
      common-pc-ssd
    ]);

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "virtio_pci" "sd_mod" ];
  boot.initrd.kernelModules = [ "virtio_gpu" ];

  boot.kernelParams = [ "tcp_bbr" ];
  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "fs.inotify.max_user_watches" = "100000";
    "net.ipv4.ip_unprivileged_port_start" = 0;
  };
  boot.extraModulePackages = [ ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/cc4ce873-6cb1-45cb-b8e6-c537580a5a6b";
      fsType = "btrfs";
      options = [ "compress=zstd" ];
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/12CE-A600";
      fsType = "vfat";
    };

  swapDevices = [{ device = "/dev/disk/by-uuid/6a1a4bf0-a728-4cdb-886c-cdc0449435fa"; }];

  networking = {
    hostName = "relay";
  };

  services.ninjasight = {
    enable = true;
    configFile = config.sops.secrets.ninjasight-config.path;
  };

  services = {
    relay-network.enable = true;
    sakurafountain.enable = true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  system.stateVersion = "23.11";
}
