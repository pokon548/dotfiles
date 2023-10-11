{ config, inputs, lib, pkgs, modulesPath, ... }:

{
  imports = [
    "${inputs.nixpkgs}/nixos/modules/profiles/qemu-guest.nix"
  ] ++ (with inputs.nixos-hardware.nixosModules;
    [
      common-pc-ssd
    ]);

  environment.systemPackages = [ pkgs.cifs-utils ];

  sops = {
    secrets = {
      cifs-username = {
        sopsFile = ../../../secrets/hetzner.yaml;
      };
      cifs-password = {
        sopsFile = ../../../secrets/hetzner.yaml;
      };
      cifs-domain = {
        sopsFile = ../../../secrets/hetzner.yaml;
      };
    };
  };

  sops.templates."smb-secrets".content = ''
    username=${config.sops.placeholder."cifs-username"}
    domain=${config.sops.placeholder."cifs-domain"}
    password=${config.sops.placeholder."cifs-password"}
  '';

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "virtio_pci" "sd_mod" ];
  boot.initrd.kernelModules = [ "virtio_gpu" ];
  boot.kernelParams = [ "console=tty" ];
  boot.extraModulePackages = [ ];

  boot.loader.systemd-boot.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_latest;

  fileSystems."/" =
    {
      device = "/dev/sda2";
      fsType = "btrfs";
      options = [ "compress=zstd" ];
    };

  fileSystems."/boot" =
    {
      device = "/dev/sda1";
      fsType = "vfat";
    };

  fileSystems."/mnt/external-storage" = {
    device = "//u370687-sub1.your-storagebox.de/u370687-sub1";
    fsType = "cifs";
    options =
      let
        # this line prevents hanging on network split
        automount_opts = "x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s";

      in
      [ "${automount_opts},credentials=${config.sops.templates."smb-secrets".path}" ];
  };

  networking = {
    useDHCP = lib.mkDefault true;
    hostName = "hetzner";
    interfaces = {
      enp1s0.ipv6.addresses = [{
        address = "2a01:4f9:c010:a9ed::add:6";
        prefixLength = 64;
      }];
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp1s0";
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  system.stateVersion = "23.11";
}
