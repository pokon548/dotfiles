{ config, lib, ... }:

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
    };
  };
}
