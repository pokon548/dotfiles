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
          START_SSH_SERVER = true;
          SSH_PORT = 22222;
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

    networking.firewall =
      {
        allowedTCPPorts = [ 22222 ];
        allowedUDPPorts = [ 22222 ];
      };

    systemd.services.gitea = {
      path = [ pkgs.bash ];
      serviceConfig.LimitNOFILE = 65536;
    };
  };
}
