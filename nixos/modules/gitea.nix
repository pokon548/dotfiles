{ config, lib, pkgs, ... }:

let
  cfg = config.networking.gitea-server;
in
{
  options = {
    networking.gitea-server = with lib; {
      enable = mkEnableOption (mdDoc "Gitea server");
    };
  };

  config = lib.mkIf cfg.enable {
    services.gitea = {
      enable = true;
      settings = {
        service = {
          DISABLE_REGISTRATION = true;
        };
        server = {
          ROOT_URL = "https://gitea.bukn.uk";
        };
        log = {
          MODE = "console";
          LEVEL = "Debug";
          ROUTER = "console";
        };
        other = {
          SHOW_FOOTER_VERSION = false;
        };
      };
      stateDir = "/mnt/external-storage/gitea";
      database = {
        type = "postgres";
        user = "gitea";
        password = "gitea";
      };
    };

    systemd.services.gitea = {
      path = [ pkgs.bash ];
      serviceConfig.LimitNOFILE = 65536;
    };
  };
}
