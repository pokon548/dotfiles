{ config, lib, pkgs, ... }:

let
  cfg = config.networking.seafile-server;
in
{
  options = {
    networking.seafile-server = with lib; {
      enable = mkEnableOption (mdDoc "Seafile server");
    };
  };

  config = lib.mkIf cfg.enable {
    services.seafile = {
      enable = true;
      adminEmail = "seafile@bukn.uk";
      ccnetSettings = {
        General.SERVICE_URL = "https://cloud-next.bukn.uk";
      };
      initialAdminPassword = "asecretinti";
    };
  };
}
