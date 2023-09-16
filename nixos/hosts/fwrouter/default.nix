{ config, inputs, lib, pkgs, modulesPath, ... }:

{
  imports = with inputs.nixos-hardware.nixosModules;
    [
      common-pc-ssd
      common-cpu-intel
    ];

  disko.devices = import ./disko-config.nix {
    inherit lib;
  };

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.loader.grub.enable = true;


  boot.kernelPackages = pkgs.linuxPackages_latest;

  hardware.enableRedistributableFirmware = true;

  networking = {
    useDHCP = lib.mkDefault true;
    hostName = "fwrouter";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  system.stateVersion = "23.11";
}
