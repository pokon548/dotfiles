{ config, lib, pkgs, ... }:

let
  cfg = config.networking.microbin-server;
in
{
  options = {
    networking.microbin-server = with lib; {
      enable = mkEnableOption (mdDoc "Microbin server");

      stateDir = mkOption {
        type = types.str;
      };

      environmentFile = mkOption {
        type = types.path;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.microbin = {
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      description = "microbin daemon";
      serviceConfig = {
        Type = "simple";
        User = "nobody";
        RootDirectory = "/";
        WorkingDirectory = "${cfg.stateDir}";

        ExecStart = "${pkgs.microbin}/bin/microbin";
      };

      serviceConfig.EnvironmentFile = cfg.environmentFile;
    };
  };
}
