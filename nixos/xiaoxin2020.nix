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
    device = "/dev/disk/by-uuid/3d9a75e3-2f54-45ea-b679-ef5297e72397";
    preLVM = true;
  };

  fileSystems."/" =
    { device = "/dev/mapper/MyVolGroup-root";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/CDDF-AEBF";
      fsType = "vfat";
    };

  zramSwap = {
    enable = true;
    writebackDevice = "/dev/mapper/MyVolGroup-swap";
  };

  hardware.enableRedistributableFirmware = true;

  networking = {
    useDHCP = lib.mkDefault true;
    hostName = "xiaoxin";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
