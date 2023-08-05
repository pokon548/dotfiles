{ config, inputs, lib, pkgs, modulesPath, ... }:

{
  imports = with inputs.nixos-hardware.nixosModules;
    [ 
      common-pc-ssd
      common-cpu-intel

      ../home-manager/pokon548.nix
      ../home-manager/zenarea.nix
      ./software/workstation.nix
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/66fdf319-d6ef-4a8b-a41e-e96762d68b6d";
    preLVM = true;
  };

  fileSystems."/" =
    { device = "/dev/mapper/MyVolGroup-root";
      fsType = "xfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/EDFC-BAAD";
      fsType = "vfat";
    };

  zramSwap = {
    enable = true;
    writebackDevice = "/dev/mapper/MyVolGroup-swap";
  };

  hardware.enableRedistributableFirmware = true;

  networking = {
    useDHCP = lib.mkDefault true;
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
