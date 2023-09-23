# This machine should only coupled with microvm. DO NOT USE IT IN REAL MACHINE

{ config, lib, pkgs, ... }: {
  networking = {
    useDHCP = lib.mkDefault true;
    hostName = "workvm";
  };

  services.xserver = {
    enable = true;
    desktopManager.lxqt.enable = true;
  };

  # TODO: Known to be broken on wayland. See https://gitlab.freedesktop.org/spice/linux/vd_agent/-/issues/26
  services.spice-vdagentd.enable = true;

  system.stateVersion = config.system.nixos.version;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.opengl.enable = true;
}
