{ config, inputs, lib, pkgs, modulesPath, ... }:

{
  sops = {
    defaultSopsFile = lib.mkForce ../../../secrets/hetzner.yaml;
    secrets = {
      microbin-username = { };
      microbin-password = { };

      pinepea-config = {
        format = "binary";
        sopsFile = ../../../secrets/pinepea;
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

  boot.kernelParams = [ "tcp_bbr" "console=tty" ];
  boot.kernel.sysctl = {
    "net.ipv4.tcp_congestion_control" = "bbr";
    "fs.inotify.max_user_watches" = "100000";
  };
  boot.extraModulePackages = [ ];

  boot.loader.systemd-boot.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_6_5; # TODO: https://github.com/NixOS/nixpkgs/issues/265521

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

  networking.samba.hetzner = true;

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
    wiki-js-server = {
      enable = true;
      stateDir = "/mnt/external-storage/wiki-js";
    };
    umami-server = {
      enable = true;
    };
  };

  sops.templates."microbin-env".content = ''
    MICROBIN_ADMIN_USERNAME=${config.sops.placeholder."microbin-username"}
    MICROBIN_ADMIN_PASSWORD=${config.sops.placeholder."microbin-password"}
    MICROBIN_UPLOADER_PASSWORD=${config.sops.placeholder."microbin-password"}
    MICROBIN_PORT=36721
    MICROBIN_BIND=0.0.0.0
    MICROBIN_NO_LISTING=true
    MICROBIN_ENABLE_BURN_AFTER=true
    MICROBIN_ENCRYPTION_SERVER_SIDE=true
    MICROBIN_FOOTER_TEXT=This is a private instance of <a href="https://microbin.eu/">MicroBin</a>. <b>We do not accept public uploads</b>.
    MICROBIN_JSON_DB=true
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
