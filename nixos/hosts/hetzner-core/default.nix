{ config, inputs, lib, pkgs, modulesPath, ... }:

{
  sops = {
    defaultSopsFile = lib.mkForce ../../../secrets/hetzner-core.yaml;
    secrets = {
      "authentik/secret-key" = { };
      "authentik/email-password" = { };
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

  swapDevices = [{ device = "/swap/swapfile"; }];

  networking = {
    useDHCP = lib.mkDefault true;
    hostName = "hetzner-core";
    interfaces = {
      enp1s0.ipv6.addresses = [{
        address = "2a01:4f8:1c1b:6290::add:6";
        prefixLength = 64;
      }];
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "enp1s0";
    };
  };

  sops.templates."authentik-env".content = ''
    AUTHENTIK_SECRET_KEY=${config.sops.placeholder."authentik/secret-key"}
    AUTHENTIK_EMAIL__PASSWORD=${config.sops.placeholder."authentik/email-password"}
  '';

  services.authentik = {
    enable = true;
    # The environmentFile needs to be on the target host!
    # Best use something like sops-nix or agenix to manage it
    environmentFile = config.sops.templates."authentik-env".path;
    settings = {
      email = {
        host = "mail.smtp2go.com";
        port = 587;
        username = "bukun-authentik@bukn.uk";
        use_tls = true;
        use_ssl = false;
        from = "bukun-authentik@bukn.uk";
      };
      disable_startup_analytics = true;
      avatars = "initials";
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  system.stateVersion = "23.11";
}
