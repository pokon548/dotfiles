{ config, inputs, lib, pkgs, modulesPath, ... }:

{
  imports = with inputs.nixos-hardware.nixosModules;
    [
      common-pc-ssd
      common-cpu-intel
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/3d9a75e3-2f54-45ea-b679-ef5297e72397";
    preLVM = true;
  };

  fileSystems."/" =
    {
      device = "/dev/mapper/MyVolGroup-root";
      fsType = "btrfs";
      options = [ "compress=zstd" ];
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/CDDF-AEBF";
      fsType = "vfat";
    };

  zramSwap = {
    enable = true;
    memoryPercent = 100;
    writebackDevice = "/dev/mapper/MyVolGroup-swap";
  };

  hardware.enableRedistributableFirmware = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  services.undervolt = {
    enable = true;
    coreOffset = -70;
  };

  time.timeZone = "Asia/Shanghai";

  hardware.nvidia = {
    modesetting.enable = true;
    powerManagement.enable = true;
    open = false;
    nvidiaSettings = true;
    prime = {
      offload = {
        enable = true;
        enableOffloadCmd = true;
      };

      # Make sure to use the correct Bus ID values for your system!
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };

    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  networking = {
    useDHCP = lib.mkDefault true;
    hostName = "xiaoxin";
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  system.stateVersion = "23.11";
}
