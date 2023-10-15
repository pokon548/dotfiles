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
      appName = "Bu Kun 的 Gitea";
      settings = {
        service = {
          DISABLE_REGISTRATION = true;
        };
        server = {
          ROOT_URL = "https://gitea.bukn.uk";
          START_SSH_SERVER = true;
          SSH_PORT = 22222;
          HTTP_PORT = 3001;
        };
        actions = {
          ENABLED = true;
        };
        other = {
          SHOW_FOOTER_VERSION = false;
        };
        log = {
          ROOT_PATH = "/mnt/external-storage/gitea/log";
          LEVEL = "Info";
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
      after = [ "mnt-external\x2dstorage-gitea.mount" "var-lib-gitea.mount" ];
      path = [ pkgs.bash ];
    };

    networking.firewall =
      {
        allowedTCPPorts = [ 22222 ];
        allowedUDPPorts = [ 22222 ];
      };
  };
}
