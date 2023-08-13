{ inputs, outputs, lib, config, pkgs, ... }: {
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
    inputs.nur.nixosModules.nur
    inputs.sops-nix.nixosModules.sops
    inputs.home-manager.nixosModules.home-manager
  ];

  nixpkgs = {
    overlays = [ inputs.nur.overlay inputs.rust-overlay.overlays.default ];

    config = { allowUnfree = true; };
  };

  sops = {
    defaultSopsFile = ../secrets/common.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}")
      config.nix.registry;

    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      substituters = [
        "https://mirrors.bfsu.edu.cn/nix-channels/store"
        "https://nix-community.cachix.org"
        "https://cache.nixos.org/"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    };
  };

  # Automatically download and prepare for latest packages.
  #
  # But keep the current one intact for stability purpose :)
  system.autoUpgrade = {
    enable = true;
    dates = "Fri 04:00";
    operation = "boot";
  };

  networking = { networkmanager.enable = true; };

  i18n.defaultLocale = "zh_CN.UTF-8";
  time.timeZone = "Asia/Shanghai";

  boot.loader.systemd-boot.enable = lib.mkForce false;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/etc/secureboot";
  };

  system.stateVersion = "23.11";
}
