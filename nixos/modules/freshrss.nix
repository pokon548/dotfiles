{ config, lib, pkgs, ... }:

let
  cfg = config.networking.freshrss-server;
in
{
  options = {
    networking.freshrss-server = with lib; {
      enable = mkEnableOption (mdDoc "FreshRSS server");
      baseUrl = mkOption {
        type = types.str;
      };
      passFile = mkOption {
        type = types.path;
      };
      passwordFile = mkOption {
        type = types.path;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.freshrss = {
      enable = true;
      baseUrl = cfg.baseUrl;
      passwordFile = cfg.passwordFile;
      database = {
        type = "pgsql";
        passFile = cfg.passFile;
        port = 5432;
        host = "localhost";
      };
    };
  };
}
