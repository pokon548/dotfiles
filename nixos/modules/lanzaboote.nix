{ lib, ... }: {
  boot = {
    loader.systemd-boot.enable = lib.mkForce false;
    lanzaboote = {
      enable = true;
      configurationLimit = 28;
      pkiBundle = "/etc/secureboot";
    };
  };
}
