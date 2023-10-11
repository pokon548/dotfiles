{ config, inputs, lib, pkgs, modulesPath, ... }:

{
  imports = with inputs.nixos-hardware.nixosModules;
    [
      common-pc-ssd
      common-cpu-intel
    ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
    "tpm"
    "tpm_tis"
    "tpm_crb"
  ];
  boot.initrd.kernelModules = [ "kvm-intel" ];
  boot.kernelParams = [ "intel_iommu=on" ];
  boot.extraModulePackages = [ ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.plymouth = {
    enable = true;
    theme = "breeze";
  };

  boot.kernel.sysctl = {
    "kernel.sysrq" = 1;
  };

  boot.initrd.systemd.enable = true;

  boot.initrd.luks.devices."cryptroot" = {
    device = "/dev/disk/by-uuid/3d9a75e3-2f54-45ea-b679-ef5297e72397";
    preLVM = true;
    allowDiscards = true;
  };

  boot.resumeDevice = "/dev/mapper/MyVolGroup-swap";

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

  swapDevices = [
    {
      device = "/dev/mapper/MyVolGroup-swap";
    }
  ];

  hardware.enableRedistributableFirmware = true;
  networking.fwrouter.enable = true;

  hardware.bluetooth = {
    enable = true;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
        ControllerMode = "dual";
        FastConnectable = "true";
        Experimental = "true";
      };
      Policy = {
        AutoEnable = "true";
      };
    };
  };

  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
  };

  environment.systemPackages = with pkgs; [
    tpm2-tools
  ];

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  services.xserver.videoDrivers = [ "nvidia" ];

  services.undervolt = {
    enable = true;
    coreOffset = -70;
    analogioOffset = -50;
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

  virtualisation.spiceUSBRedirection.enable = true;
  system.stateVersion = "23.11";
}
