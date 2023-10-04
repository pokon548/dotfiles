{ config, inputs, lib, pkgs, modulesPath, ... }:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/virtualisation/qemu-vm.nix"
  ] ++ (with inputs.nixos-hardware.nixosModules;
  [
    common-pc-ssd
  ]);

  disko.devices = import ./disko-config.nix {
    inherit lib;
  };

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.loader.grub = {
    enable = true;
    device = "/dev/vda";
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking = {
    useDHCP = lib.mkDefault true;
    hostName = "hetzner";
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  system.stateVersion = "23.11";
}
