{ config, lib, pkgs, ... }:

let
  cfg = config.services.ntfy-server;
in
{
  options = {
    services.ntfy-server = with lib; {
      enable = mkEnableOption (mdDoc "Ntfy.sh server");

      stateDir = mkOption {
        type = types.str;
        default = "/var/lib/ntfy";
      };

      baseUrl = mkOption {
        type = types.str;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    services.ntfy-sh = {
      enable = true;
      settings = {
        listen-http = ":33871";

        auth-file = "${cfg.stateDir}/user.db";
        auth-default-access = "deny-all";

        base-url = "${cfg.baseUrl}";
        cache-file = "${cfg.stateDir}/cache.db";
        attachment-cache-dir = "${cfg.stateDir}/attachments";

        behind-proxy = true;
      };
    };
  };
}
