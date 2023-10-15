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
      gitea-cifs-username = {
        sopsFile = ../../../secrets/hetzner.yaml;
      };
      gitea-cifs-password = {
        sopsFile = ../../../secrets/hetzner.yaml;
      };
      gitea-cifs-domain = {
        sopsFile = ../../../secrets/hetzner.yaml;
      };

      seafile-cifs-username = {
        sopsFile = ../../../secrets/hetzner.yaml;
      };
      seafile-cifs-password = {
        sopsFile = ../../../secrets/hetzner.yaml;
      };
      seafile-cifs-domain = {
        sopsFile = ../../../secrets/hetzner.yaml;
      };

      microbin-cifs-username = {
        sopsFile = ../../../secrets/hetzner.yaml;
      };
      microbin-cifs-password = {
        sopsFile = ../../../secrets/hetzner.yaml;
      };
      microbin-cifs-domain = {
        sopsFile = ../../../secrets/hetzner.yaml;
      };

      microbin-username = {
        sopsFile = ../../../secrets/hetzner.yaml;
      };
      microbin-password = {
        sopsFile = ../../../secrets/hetzner.yaml;
      };

      pinepea-config = {
        format = "binary";
        sopsFile = ../../../secrets/pinepea;
      };
    };
  };

  sops.templates."gitea-smb-secrets".content = ''
    username=${config.sops.placeholder."gitea-cifs-username"}
    domain=${config.sops.placeholder."gitea-cifs-domain"}
    password=${config.sops.placeholder."gitea-cifs-password"}
  '';

  sops.templates."seafile-smb-secrets".content = ''
    username=${config.sops.placeholder."seafile-cifs-username"}
    domain=${config.sops.placeholder."seafile-cifs-domain"}
    password=${config.sops.placeholder."seafile-cifs-password"}
  '';

  sops.templates."microbin-smb-secrets".content = ''
    username=${config.sops.placeholder."microbin-cifs-username"}
    domain=${config.sops.placeholder."microbin-cifs-domain"}
    password=${config.sops.placeholder."microbin-cifs-password"}
  '';

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "virtio_pci" "sd_mod" ];
  boot.initrd.kernelModules = [ "virtio_gpu" ];

  boot.kernelParams = [ "tcp_bbr" "console=tty" ];
  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "fs.inotify.max_user_watches" = "100000";
  };
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

  fileSystems."/mnt/external-storage/gitea" = {
    device = "//u370687-sub2.your-storagebox.de/u370687-sub2";
    fsType = "cifs";
    options =
      let
        # this line prevents hanging on network split
        automount_opts = "_netdev,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,mfsymlinks,uid=995,gid=995";

      in
      [ "${automount_opts},credentials=${config.sops.templates."gitea-smb-secrets".path}" ];
  };

  fileSystems."/mnt/external-storage/seafile" = {
    device = "//u370687-sub3.your-storagebox.de/u370687-sub3";
    fsType = "cifs";
    options =
      let
        # this line prevents hanging on network split
        automount_opts = "_netdev,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,mfsymlinks,uid=995,gid=995";

      in
      [ "${automount_opts},credentials=${config.sops.templates."seafile-smb-secrets".path}" ];
  };

  fileSystems."/mnt/external-storage/pastebin" = {
    device = "//u370687-sub5.your-storagebox.de/u370687-sub5";
    fsType = "cifs";
    options =
      let
        # this line prevents hanging on network split
        automount_opts = "_netdev,x-systemd.automount,noauto,x-systemd.idle-timeout=60,x-systemd.device-timeout=5s,x-systemd.mount-timeout=5s,mfsymlinks,uid=65534,gid=65534";

      in
      [ "${automount_opts},credentials=${config.sops.templates."microbin-smb-secrets".path}" ];
  };

  swapDevices = [{ device = "/swap/swapfile"; }];

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

    gitea-server.enable = true;
    #seafile-server.enable = true;  // FIXME: Not working for unstable
    microbin-server = {
      enable = true;
      stateDir = "/mnt/external-storage/pastebin";
      environmentFile = config.sops.templates."microbin-env".path;
    };
  };

  sops.templates."microbin-env".content = ''
    MICROBIN_ADMIN_USERNAME=${config.sops.placeholder."microbin-username"}
    MICROBIN_ADMIN_PASSWORD=${config.sops.placeholder."microbin-password"}
    MICROBIN_PORT=36721
    MICROBIN_BIND=0.0.0.0
    MICROBIN_NO_LISTING=true
    MICROBIN_READONLY=true
  '';

  services.pinepea = {
    enable = true;
    configFile = config.sops.secrets.pinepea-config.path;
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  system.stateVersion = "23.11";
}
