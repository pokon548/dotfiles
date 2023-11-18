{ config, lib, pkgs, ... }:

let
  cfg = config.networking.kosync-server;
in
{
  options = {
    networking.kosync-server = with lib; {
      enable = mkEnableOption (mdDoc "Koreader sync server");

      stateDir = mkOption {
        type = types.str;
      };

      port = mkOption {
        type = types.port;
        default = 7200;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.oci-containers = {
      backend = "podman";
      containers = {
        kosync-server = {
          autoStart = true;
          image = "docker.io/b1n4ryj4n/koreader-sync:arm";
          ports = [
            "${builtins.toString cfg.port}:8081"
          ];
          volumes = [
            "${cfg.stateDir}/data:/app/data"
          ];
          user = "nobody:nogroup";
        };
      };
    };
  };
}
