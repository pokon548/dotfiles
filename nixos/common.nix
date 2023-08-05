{ inputs, outputs, lib, config, pkgs, ... }: {
  imports = [
  ];

  nixpkgs = {
    overlays = [
      inputs.nur.overlay
    ];

    config = {
      allowUnfree = true;
    };
  };

  sops = {
    defaultSopsFile = ../secrets/common.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  nixpkgs.config.packageOverrides = pkgs: {
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };

  networking = {
    networkmanager.enable = true;
  };

  i18n.defaultLocale = "zh_CN.UTF-8";
  time.timeZone = "Asia/Shanghai";

  boot.loader.systemd-boot.enable = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  #boot.lanzaboote = {
  #  enable = true;
  #  pkiBundle = "/etc/secureboot";
  #};

  system.stateVersion = "23.11";
}
